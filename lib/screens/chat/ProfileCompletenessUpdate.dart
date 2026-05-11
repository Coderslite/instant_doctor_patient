import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/LocationController.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

class ProfileCompletenessUpdate extends StatefulWidget {
  final UserModel user;
  const ProfileCompletenessUpdate({super.key, required this.user});

  @override
  State<ProfileCompletenessUpdate> createState() =>
      _ProfileCompletenessUpdateState();
}

class _ProfileCompletenessUpdateState extends State<ProfileCompletenessUpdate> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController addressController;
  late TextEditingController phoneController;

  String? bloodGroup;
  String? genotype;
  DateTime? dob;
  String completePhoneNumber = '';

  @override
  void initState() {
    super.initState();
    heightController =
        TextEditingController(text: widget.user.height.validate());
    weightController =
        TextEditingController(text: widget.user.weight.validate());
    addressController =
        TextEditingController(text: widget.user.address.validate());
    phoneController =
        TextEditingController(text: widget.user.phoneNumber.validate());
    completePhoneNumber = widget.user.phoneNumber.validate();
    bloodGroup = widget.user.bloodGroup.validate().isEmpty
        ? null
        : widget.user.bloodGroup;
    genotype =
        widget.user.genotype.validate().isEmpty ? null : widget.user.genotype;
    dob = widget.user.dob?.toDate();
  }

  bool get isMedicalMissing =>
      widget.user.bloodGroup.validate().isEmpty ||
      widget.user.height.validate().isEmpty ||
      widget.user.weight.validate().isEmpty ||
      widget.user.genotype.validate().isEmpty;

  bool get isPersonalMissing =>
      widget.user.dob == null ||
      widget.user.address.validate().isEmpty ||
      widget.user.phoneNumber.validate().isEmpty;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{};

    if (heightController.text.isNotEmpty) {
      data['height'] = heightController.text;
    }
    if (weightController.text.isNotEmpty) {
      data['weight'] = weightController.text;
    }
    if (bloodGroup != null) data['bloodGroup'] = bloodGroup;
    if (genotype != null) data['genotype'] = genotype;
    if (dob != null) data['dob'] = Timestamp.fromDate(dob!);
    if (addressController.text.isNotEmpty) {
      data['address'] = addressController.text;
    }
    if (completePhoneNumber.isNotEmpty) {
      data['phoneNumber'] = completePhoneNumber;
    }

    if (data.isEmpty) {
      finish(context);
      return;
    }

    try {
      await userService.updateProfile(
        data: data,
        userId: userController.userId.value,
      );
      toast("Profile updated successfully");
      if (mounted) finish(context);
    } catch (e) {
      toast("Failed to update profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              24.height,
              const Text(
                "Complete Your Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: kText,
                  letterSpacing: -0.5,
                ),
              ),
              8.height,
              const Text(
                "Please provide the missing information to proceed with your consultation.",
                style: TextStyle(fontSize: 14, color: kSub, height: 1.4),
              ),
              32.height,
              if (isPersonalMissing) ...[
                _buildSectionHeader(
                    "Personal Details", Icons.person_outline_rounded),
                16.height,
                _buildDatePicker(),
                16.height,
                _buildPhoneField(),
                16.height,
                _buildAddressField(),
                32.height,
              ],
              if (isMedicalMissing) ...[
                _buildSectionHeader(
                    "Medical Information", Icons.medical_services_outlined),
                16.height,
                Row(
                  children: [
                    Expanded(
                        child: _buildDropdownField(
                            "Blood Group",
                            bloodGroup,
                            ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                            (val) => setState(() => bloodGroup = val))),
                    16.width,
                    Expanded(
                        child: _buildDropdownField(
                            "Genotype",
                            genotype,
                            ['AA', 'AS', 'SS', 'AC', 'SC'],
                            (val) => setState(() => genotype = val))),
                  ],
                ),
                16.height,
                Row(
                  children: [
                    Expanded(
                        child: _buildInputField(
                            "Height", heightController, "cm", Icons.height)),
                    16.width,
                    Expanded(
                        child: _buildInputField("Weight", weightController,
                            "kg", Icons.monitor_weight_outlined)),
                  ],
                ),
                32.height,
              ],
              PremiumButton(
                onTap: _handleSave,
                text: "Save & Continue",
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimary),
        8.width,
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: kPrimary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date of Birth",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        8.height,
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dob ??
                  DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: kPrimary),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => dob = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 20, color: kPrimary.withOpacity(0.5)),
                12.width,
                Text(
                  dob != null
                      ? formatDateWithoutTime(dob!)
                      : "Select Birth Date",
                  style: TextStyle(
                    fontSize: 15,
                    color: dob != null ? kText : kSub.withOpacity(0.4),
                    fontWeight:
                        dob != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Home Address",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        8.height,
        InkWell(
          onTap: () async {
            await const ChangePickup().launch(context);
            // Refresh address from controller after returning
            setState(() {
              addressController.text =
                  Get.find<LocationController>().address.value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 20, color: kPrimary.withOpacity(0.5)),
                12.width,
                Expanded(
                  child: Text(
                    addressController.text.isEmpty
                        ? "Select Address"
                        : addressController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: addressController.text.isNotEmpty
                          ? kText
                          : kSub.withOpacity(0.4),
                      fontWeight: addressController.text.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20, color: kSub),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        8.height,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text("Select",
                  style: TextStyle(color: kSub.withOpacity(0.4), fontSize: 14)),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Phone Number",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        8.height,
        IntlPhoneField(
          controller: phoneController,
          initialCountryCode: 'US',
          onChanged: (phone) {
            completePhoneNumber = phone.completeNumber;
          },
          decoration: InputDecoration(
            hintText: "Phone Number",
            fillColor: kBg,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      String unit, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        8.height,
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "00",
            suffixText: unit,
            prefixIcon: Icon(icon, size: 20, color: kPrimary.withOpacity(0.5)),
            fillColor: kBg,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}

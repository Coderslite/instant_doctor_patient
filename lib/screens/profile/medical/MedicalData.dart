import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../services/GetUserId.dart';

class MedicalDataScreen extends StatefulWidget {
  final bool isModal;
  const MedicalDataScreen({super.key, required this.isModal});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<UserModel>(
          stream: userService.getProfile(userId: userController.userId.value),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: kPrimary));
            }

            final data = snapshot.data!;
            final profileCompleted = data.bloodGroup.validate().isNotEmpty &&
                data.height.validate().isNotEmpty &&
                data.weight.validate().isNotEmpty &&
                data.genotype.validate().isNotEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      backButton(context).visible(!widget.isModal),
                      Text(
                        "Medical Data",
                        style: boldTextStyle(size: 20, color: kPrimary),
                      ),
                      const SizedBox(width: 40), // For balance
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile Completion Status
                  if (!profileCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: coral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_services_outlined,
                              size: 16, color: coral),
                          const SizedBox(width: 8),
                          Text(
                            "Complete your medical profile",
                            style: primaryTextStyle(color: coral),
                          ),
                        ],
                      ),
                    ).center(),
                  const SizedBox(height: 32),

                  // Medical Sections
                  Text("VITAL STATISTICS", style: secondaryTextStyle(size: 12)),
                  const SizedBox(height: 8),
                  _buildMedicalSection(
                    title: "Body Measurements",
                    children: [
                      _buildMedicalOption(
                        icon: Icons.height,
                        title: "Height",
                        value: data.height.validate(),
                        unit: "cm",
                        key: "height",
                      ),
                      _buildMedicalOption(
                        icon: Icons.monitor_weight_outlined,
                        title: "Weight",
                        value: data.weight.validate(),
                        unit: "kg",
                        key: "weight",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text("BLOOD INFORMATION",
                      style: secondaryTextStyle(size: 12)),
                  const SizedBox(height: 8),
                  _buildMedicalSection(
                    title: "Blood Details",
                    children: [
                      _buildMedicalOption(
                        icon: Icons.bloodtype_outlined,
                        title: "Blood Group",
                        value: data.bloodGroup.validate(),
                        key: "bloodGroup",
                      ),
                      _buildMedicalOption(
                        icon: Icons.dns_outlined,
                        title: "Genotype",
                        value: data.genotype.validate(),
                        key: "genotype",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text("ADDITIONAL INFORMATION",
                      style: secondaryTextStyle(size: 12)),
                  const SizedBox(height: 8),
                  _buildMedicalSection(
                    title: "Medical History",
                    children: [
                      _buildMedicalOption(
                        icon: Icons.family_restroom_outlined,
                        title: "Marital Status",
                        value: data.maritalStatus.validate(),
                        key: "maritalStatus",
                      ),
                      _buildMedicalOption(
                        icon: Icons.medical_services_outlined,
                        title: "Surgery History",
                        value: data.surgicalHistory.validate(),
                        key: "surgicalHistory",
                      ),
                    ],
                  ),
                  10.height,
                  AppButton(
                    onTap: () {
                      finish(context);
                    },
                    text: "Continue",
                    width: double.infinity,
                    color: kPrimary,
                    textColor: white,
                  ).visible(widget.isModal),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicalSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: boldTextStyle(size: 16)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalOption({
    required IconData icon,
    required String title,
    required String value,
    required String key,
    String? unit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: kPrimary),
        title: Text(title, style: secondaryTextStyle(size: 12)),
        subtitle: Text(
          value.isEmpty ? "Not set" : value,
          style: boldTextStyle(size: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unit != null) Text(unit, style: secondaryTextStyle()),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => _handleMedicalOptionTap(key, value, title),
      ),
    );
  }

  void _handleMedicalOptionTap(
      String key, String currentValue, String title) async {
    final controller = TextEditingController(text: currentValue);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildMedicalEditSheet(key, controller, title),
    );
  }

  Widget _buildMedicalEditSheet(
      String key, TextEditingController controller, String title) {
    final isDropdown = key == 'bloodGroup' ||
        key == 'genotype' ||
        key == 'maritalStatus' ||
        key == 'surgicalHistory';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update $title",
              style: boldTextStyle(size: 18),
            ),
            const SizedBox(height: 20),
            if (isDropdown) ...[
              _buildMedicalDropdown(key, controller),
            ] else ...[
              AppTextField(
                controller: controller,
                textFieldType: TextFieldType.NUMBER,
                decoration: InputDecoration(
                  labelText: "Enter your $title",
                  hintText: key == 'height' ? "In centimeters" : "In kilograms",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixText: key == 'height' ? 'cm' : 'kg',
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: kPrimary),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child:
                        Text("Cancel", style: boldTextStyle(color: kPrimary)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        await userService.updateProfile(
                          data: {key: controller.text},
                          userId: userController.userId.value,
                        );
                        Navigator.pop(context);
                        toast("Medical data updated successfully");
                      }
                    },
                    child:
                        Text("Save", style: boldTextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalDropdown(String key, TextEditingController controller) {
    List<String> items = [];

    if (key == 'bloodGroup') {
      items = [
        'A(positive)',
        'A(negative)',
        'B(positive)',
        'B(negative)',
        'AB(positive)',
        'AB(negative)',
        'O(positive)',
        'O(negative)',
      ];
    } else if (key == 'genotype') {
      items = ['AA', 'AS', 'SS', 'AC', 'SC'];
    } else if (key == 'maritalStatus') {
      items = ['Single', 'Married', 'Divorced', 'Widowed'];
    } else if (key == 'surgicalHistory') {
      items = ['None', 'Minor surgery', 'Major surgery', 'Multiple surgeries'];
    }

    return DropdownButtonFormField(
      value: controller.text.isEmpty ? null : controller.text,
      style: primaryTextStyle(),
      dropdownColor: context.cardColor,
      decoration: InputDecoration(
        labelText: "Select option",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: (val) => controller.text = val.toString(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../component/PremiumButton.dart';
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
      backgroundColor: kBg,
      body: SafeArea(
        child: StreamBuilder<UserModel>(
          stream: userService.getProfile(userId: userController.userId.value),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: Loader());

            final data = snapshot.data!;
            final profileCompleted = data.bloodGroup.validate().isNotEmpty &&
                data.height.validate().isNotEmpty &&
                data.weight.validate().isNotEmpty &&
                data.genotype.validate().isNotEmpty;

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (!widget.isModal) ...[
                        backButton(context),
                        24.width,
                      ],
                      const Text(
                        "Medical Data",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: kText,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!profileCompleted) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medical_information_rounded, color: Colors.redAccent, size: 20),
                                12.width,
                                const Expanded(
                                  child: Text(
                                    "Your medical profile is incomplete. Please provide your vitals for better care.",
                                    style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          24.height,
                        ],

                        _buildSectionLabel("VITAL STATISTICS"),
                        8.height,
                        _buildMenuGroup([
                          _buildMedicalOption(
                            icon: Icons.height_rounded,
                            title: "Height",
                            value: data.height.validate(),
                            unit: "cm",
                            key: "height",
                          ),
                          _buildMedicalOption(
                            icon: Icons.monitor_weight_rounded,
                            title: "Weight",
                            value: data.weight.validate(),
                            unit: "kg",
                            key: "weight",
                          ),
                        ]),

                        24.height,
                        _buildSectionLabel("BLOOD INFORMATION"),
                        8.height,
                        _buildMenuGroup([
                          _buildMedicalOption(
                            icon: Icons.bloodtype_rounded,
                            title: "Blood Group",
                            value: data.bloodGroup.validate(),
                            key: "bloodGroup",
                          ),
                          _buildMedicalOption(
                            icon: Icons.biotech_rounded,
                            title: "Genotype",
                            value: data.genotype.validate(),
                            key: "genotype",
                          ),
                        ]),

                        24.height,
                        _buildSectionLabel("ADDITIONAL DETAILS"),
                        8.height,
                        _buildMenuGroup([
                          _buildMedicalOption(
                            icon: Icons.favorite_rounded,
                            title: "Marital Status",
                            value: data.maritalStatus.validate(),
                            key: "maritalStatus",
                          ),
                          _buildMedicalOption(
                            icon: Icons.medical_services_rounded,
                            title: "Surgery History",
                            value: data.surgicalHistory.validate(),
                            key: "surgicalHistory",
                          ),
                        ]),
                        
                        32.height,
                        if (widget.isModal)
                          PremiumButton(
                            onTap: () => finish(context),
                            text: "Done",
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: kSub,
        letterSpacing: 1.2,
      ),
    ).paddingLeft(4);
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: children,
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
    bool hasValue = value.isNotEmpty && value != "Not set";
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 12, color: kSub, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            hasValue ? "$value${unit != null ? " $unit" : ""}" : "Not provided",
            style: const TextStyle(fontSize: 16, color: kText, fontWeight: FontWeight.w700),
          ).paddingTop(2),
          trailing: const Icon(Icons.chevron_right_rounded, color: kSub, size: 20),
          onTap: () => _handleMedicalOptionTap(key, value, title),
        ),
        if (key != "surgicalHistory")
          const Divider(height: 1, color: kBorder).paddingLeft(72),
      ],
    );
  }

  void _handleMedicalOptionTap(String key, String currentValue, String title) async {
    final controller = TextEditingController(text: currentValue == "Not provided" ? "" : currentValue);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMedicalEditSheet(key, controller, title),
    );
  }

  Widget _buildMedicalEditSheet(String key, TextEditingController controller, String title) {
    final isDropdown = key == 'bloodGroup' || key == 'genotype' || key == 'maritalStatus' || key == 'surgicalHistory';

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          24.height,
          Text("Update $title", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kText)),
          24.height,
          if (isDropdown) ...[
            _buildMedicalDropdown(key, controller),
          ] else ...[
            AppTextField(
              controller: controller,
              textFieldType: TextFieldType.NUMBER,
              decoration: InputDecoration(
                filled: true,
                fillColor: kBg,
                labelText: "Enter $title",
                labelStyle: const TextStyle(color: kSub),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                suffixText: key == 'height' ? 'cm' : 'kg',
              ),
            ),
          ],
          24.height,
          PremiumButton(
            onTap: () async {
              if (controller.text.isNotEmpty) {
                await userService.updateProfile(
                  data: {key: controller.text},
                  userId: userController.userId.value,
                );
                Navigator.pop(context);
                toast("Updated successfully");
              }
            },
            text: "Save Changes",
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDropdown(String key, TextEditingController controller) {
    List<String> items = [];
    if (key == 'bloodGroup') items = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    else if (key == 'genotype') items = ['AA', 'AS', 'SS', 'AC', 'SC'];
    else if (key == 'maritalStatus') items = ['Single', 'Married', 'Divorced', 'Widowed'];
    else if (key == 'surgicalHistory') items = ['None', 'Minor surgery', 'Major surgery', 'Multiple surgeries'];

    return DropdownButtonFormField(
      value: controller.text.isEmpty ? null : controller.text,
      style: const TextStyle(color: kText, fontWeight: FontWeight.w600),
      dropdownColor: kCard,
      decoration: InputDecoration(
        filled: true,
        fillColor: kBg,
        labelText: "Select option",
        labelStyle: const TextStyle(color: kSub),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) => controller.text = val.toString(),
    );
  }
}

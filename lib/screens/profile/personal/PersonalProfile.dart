import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../component/backButton.dart';
import '../../../controllers/UploadFileController.dart';
import '../../../component/PremiumButton.dart';
import '../../../main.dart';

class PersonalProfileScreen extends StatefulWidget {
  final bool isModal;
  const PersonalProfileScreen({super.key, required this.isModal});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final UploadFileController uploadFileController = Get.put(UploadFileController());
  bool isUploading = false;
  XFile? file;

  Future<void> handleChangeImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      try {
        setState(() => isUploading = true);
        file = result;
        final uploadUrl = await uploadFileController.uploadProfileImage(File(file!.path));
        await userService.updateProfile(
            data: {"photoUrl": uploadUrl}, userId: userController.userId.value);
        toast("Profile image updated successfully");
      } catch (e) {
        toast("Error uploading image");
      } finally {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    uploadFileController.progress.value = 0.0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Obx(() {
        return SafeArea(
          child: StreamBuilder<UserModel>(
            stream: userService.getProfile(userId: userController.userId.value),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: Loader());

              final data = snapshot.data!;
              final profileCompleted = data.dob != null && data.phoneNumber.validate().isNotEmpty;

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
                          "Personal Info",
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
                          // Profile Picture
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kPrimary.withOpacity(0.1), width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kText.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: isUploading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              value: uploadFileController.progress.value,
                                              color: kPrimary,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : profileImage(data, 120, 120, context: context),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: handleChangeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: kCard, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          32.height,

                          if (!profileCompleted) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amber.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                                  12.width,
                                  const Expanded(
                                    child: Text(
                                      "Please complete your profile details to get the best experience.",
                                      style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            24.height,
                          ],

                          _buildSectionLabel("BASIC INFORMATION"),
                          8.height,
                          _buildMenuGroup([
                            _buildProfileOption(
                              icon: Icons.person_outline_rounded,
                              title: "First Name",
                              value: data.firstName.validate(),
                              key: "firstname",
                            ),
                            _buildProfileOption(
                              icon: Icons.person_outline_rounded,
                              title: "Last Name",
                              value: data.lastName.validate(),
                              key: "lastname",
                            ),
                            _buildProfileOption(
                              icon: Icons.phone_android_rounded,
                              title: "Phone Number",
                              value: data.phoneNumber.validate(),
                              key: "phoneNumber",
                            ),
                            _buildProfileOption(
                              icon: Icons.email_outlined,
                              title: "Email Address",
                              value: data.email.validate(),
                              key: "email",
                              isEditable: false,
                            ),
                          ]),

                          24.height,
                          _buildSectionLabel("ADDITIONAL DETAILS"),
                          8.height,
                          _buildMenuGroup([
                            _buildProfileOption(
                              icon: Icons.cake_outlined,
                              title: "Date of Birth",
                              value: data.dob != null ? formatDateWithoutTime(data.dob!.toDate()) : "Not set",
                              key: "dob",
                            ),
                            _buildProfileOption(
                              icon: Icons.location_on_outlined,
                              title: "Home Address",
                              value: data.address.validate(),
                              key: "address",
                            ),
                            _buildProfileOption(
                              icon: Icons.wc_rounded,
                              title: "Gender",
                              value: data.gender.validate().isNotEmpty ? data.gender! : "Not set",
                              key: "gender",
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
        );
      }),
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String value,
    required String key,
    bool isEditable = true,
  }) {
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
            value.isEmpty || value == "Not set" ? "Not provided" : value,
            style: const TextStyle(fontSize: 16, color: kText, fontWeight: FontWeight.w700),
          ).paddingTop(2),
          trailing: isEditable ? const Icon(Icons.chevron_right_rounded, color: kSub, size: 20) : null,
          onTap: isEditable ? () => _handleOptionTap(key, value) : null,
        ),
        if (key != "gender" && key != "email")
          const Divider(height: 1, color: kBorder).paddingLeft(72),
      ],
    );
  }

  void _handleOptionTap(String key, String currentValue) async {
    if (key == 'dob') {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 36500)),
        lastDate: DateTime.now(),
        initialDate: currentValue.isNotEmpty && currentValue != "Not set"
            ? (userController.userModel?.dob?.toDate() ?? DateTime.now())
            : DateTime.now().subtract(const Duration(days: 365 * 18)),
      );

      if (date != null) {
        await userService.updateProfile(
          data: {"dob": Timestamp.fromDate(date)},
          userId: userController.userId.value,
        );
        toast("Date of birth updated successfully");
      }
      return;
    }

    if (key == 'address') {
      ChangePickup().launch(context);
      return;
    }

    if (key == 'gender') {
      final controller = TextEditingController(text: currentValue == 'Not set' ? null : currentValue);
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _buildGenderEditSheet(controller),
      );
      return;
    }

    final controller = TextEditingController(text: currentValue == "Not provided" ? "" : currentValue);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEditBottomSheet(key, controller),
    );
  }

  Widget _buildGenderEditSheet(TextEditingController controller) {
    return _buildBottomSheetBase(
      title: "Update Gender",
      child: Column(
        children: [
          DropdownButtonFormField(
            value: controller.text.isEmpty ? null : controller.text,
            style: const TextStyle(color: kText, fontWeight: FontWeight.w600),
            dropdownColor: kCard,
            decoration: InputDecoration(
              filled: true,
              fillColor: kBg,
              labelText: "Select Gender",
              labelStyle: const TextStyle(color: kSub),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Male', 'Female', 'Other']
                .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                .toList(),
            onChanged: (val) => controller.text = val.toString(),
          ),
          24.height,
          PremiumButton(
            onTap: () async {
              if (controller.text.isNotEmpty) {
                await userService.updateProfile(
                  data: {"gender": controller.text},
                  userId: userController.userId.value,
                );
                Navigator.pop(context);
                toast("Gender updated successfully");
              }
            },
            text: "Save Changes",
          ),
        ],
      ),
    );
  }

  Widget _buildEditBottomSheet(String key, TextEditingController controller) {
    String label = key == 'firstname' ? 'First Name' : key == 'lastname' ? 'Last Name' : key;
    return _buildBottomSheetBase(
      title: "Update $label",
      child: Column(
        children: [
          AppTextField(
            controller: controller,
            textFieldType: key == 'phoneNumber' ? TextFieldType.PHONE : TextFieldType.NAME,
            decoration: InputDecoration(
              filled: true,
              fillColor: kBg,
              labelText: "Enter $label",
              labelStyle: const TextStyle(color: kSub),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          24.height,
          PremiumButton(
            onTap: () async {
              if (controller.text.isNotEmpty) {
                await userService.updateProfile(
                  data: {key: controller.text},
                  userId: userController.userId.value,
                );
                getUserId();
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

  Widget _buildBottomSheetBase({required String title, required Widget child}) {
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
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kText)),
          24.height,
          child,
        ],
      ),
    );
  }
}

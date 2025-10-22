import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/drug/ChangePickup.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../component/backButton.dart';
import '../../../controllers/UploadFileController.dart';
import '../../../main.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  final UploadFileController uploadFileController =
      Get.put(UploadFileController());
  bool isUploading = false;
  XFile? file;

  Future<void> handleChangeImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      try {
        setState(() => isUploading = true);
        file = result;
        final uploadUrl =
            await uploadFileController.uploadProfileImage(File(file!.path));
        await userService.updateProfile(
            data: {"photoUrl": uploadUrl}, userId: userController.userId.value);
        toast("Profile image updated successfully");
      } catch (e) {
        toast("Error uploading image");
      } finally {
        setState(() => isUploading = false);
      }
    } else {
      toast("No image selected");
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
      body: Obx(() {
        final isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: StreamBuilder<UserModel>(
            stream: userService.getProfile(userId: userController.userId.value),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loader();
              }

              final data = snapshot.data!;
              final profileCompleted =
                  data.dob != null && data.phoneNumber.validate().isNotEmpty;

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
                        backButton(context),
                        Text(
                          "Personal Information",
                          style: boldTextStyle(size: 20, color: kPrimary),
                        ),
                        const SizedBox(width: 40), // For balance
                      ],
                    ),
                    const SizedBox(height: 24),

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
                              border: Border.all(
                                color: kPrimary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: isUploading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            uploadFileController.progress.value,
                                        color: kPrimary,
                                      ),
                                    )
                                  : profileImage(UserModel(), 120, 120,
                                      context: context),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit,
                                size: 18, color: Colors.white),
                          ).onTap(handleChangeImage).visible(false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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
                            Icon(Icons.info_outline, size: 16, color: coral),
                            const SizedBox(width: 8),
                            Text(
                              "Complete your profile",
                              style: primaryTextStyle(color: coral),
                            ),
                          ],
                        ),
                      ).center(),
                    const SizedBox(height: 32),

                    // Profile Sections
                    Text("PERSONAL DETAILS",
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 8),
                    _buildProfileSection(
                      title: "Basic Information",
                      children: [
                        _buildProfileOption(
                          icon: Icons.person_outline,
                          title: "First Name",
                          value: data.firstName.validate(),
                          key: "firstname",
                        ),
                        _buildProfileOption(
                          icon: Icons.person_outline,
                          title: "Last Name",
                          value: data.lastName.validate(),
                          key: "lastname",
                        ),
                        _buildProfileOption(
                          icon: Icons.phone_outlined,
                          title: "Phone Number",
                          value: data.phoneNumber.validate(),
                          key: "phoneNumber",
                        ),
                        _buildProfileOption(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: data.email.validate(),
                          key: "email",
                          isEditable: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text("ADDITIONAL INFORMATION",
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 8),
                    _buildProfileSection(
                      title: "More Details",
                      children: [
                        _buildProfileOption(
                          icon: Icons.cake_outlined,
                          title: "Date of Birth",
                          value: data.dob != null
                              ? formatDateWithoutTime(data.dob!.toDate())
                              : "Not set",
                          key: "dob",
                        ),
                        _buildProfileOption(
                          icon: Icons.location_on_outlined,
                          title: "Address",
                          value: data.address.validate(),
                          key: "address",
                        ),
                        _buildProfileOption(
                          icon: Icons.person,
                          title: "Gender",
                          value: data.gender.validate().isNotEmpty
                              ? data.gender!
                              : "Not set",
                          key: "gender",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildProfileSection({
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

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String value,
    required String key,
    bool isEditable = true,
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
        trailing: isEditable
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: isEditable ? () => _handleOptionTap(key, value) : null,
      ),
    );
  }

  void _handleOptionTap(String key, String currentValue) async {
    if (key == 'dob') {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 36500)),
        lastDate: DateTime.now(),
        initialDate: currentValue.isNotEmpty
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
      final controller = TextEditingController(
          text: currentValue == 'Not set' ? null : currentValue);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _buildGenderEditSheet(controller),
      );
      return;
    }

    final controller = TextEditingController(text: currentValue);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildEditBottomSheet(key, controller),
    );
  }

  Widget _buildGenderEditSheet(TextEditingController controller) {
    print(controller.text);
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
              "Update Gender",
              style: boldTextStyle(size: 18),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              value: controller.text.isEmpty ? null : controller.text,
              style: primaryTextStyle(),
              dropdownColor: context.cardColor,
              decoration: InputDecoration(
                labelText: "Select Gender",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (val) => controller.text = val.toString(),
            ),
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
                        print(
                            'Updating gender to: ${controller.text}'); // Debugging
                        await userService.updateProfile(
                          data: {"gender": controller.text},
                          userId: userController.userId.value,
                        );
                        Navigator.pop(context);
                        toast("Gender updated successfully");
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

  Widget _buildEditBottomSheet(String key, TextEditingController controller) {
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
              "Update ${key == 'firstname' ? 'First Name' : key == 'lastname' ? 'Last Name' : key}",
              style: boldTextStyle(size: 18),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: controller,
              textFieldType: key == 'phoneNumber'
                  ? TextFieldType.PHONE
                  : TextFieldType.NAME,
              decoration: InputDecoration(
                labelText: "Enter new value",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
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
                        getUserId();
                        Navigator.pop(context);
                        toast("Updated successfully");
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
}

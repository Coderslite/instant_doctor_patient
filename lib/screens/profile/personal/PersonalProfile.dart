// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

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
  var controller = TextEditingController();
  UploadFileController uploadFileController = Get.put(UploadFileController());
  bool isUploading = false;
  XFile? file;
  handleChangeImage() async {
    var result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      try {
        isUploading = true;
        setState(() {});

        file = result;
        var uploadUrl =
            await uploadFileController.uploadProfileImage(File(file!.path));
        await userService.updateProfile(
            data: {"photoUrl": uploadUrl}, userId: userController.userId.value);
        toast("Profile Image Updated");
      } finally {
        isUploading = false;
        setState(() {});
      }
    } else {
      toast("No image was selected");
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
        // ignore: unused_local_variable
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<UserModel>(
                stream:
                    userService.getProfile(userId: userController.userId.value),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    bool profileCompleted =
                        data.dob != null && data.address.validate().isNotEmpty;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              backButton(context),
                              Text(
                                "Personal Information",
                                style: boldTextStyle(
                                  size: 16,
                                  color: kPrimary,
                                ),
                              ),
                              Container(),
                            ],
                          ),
                          1.height,
                          Obx(
                            () {
                              var progress =
                                  uploadFileController.progress.value;
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  isUploading
                                      ? Column(
                                          children: [
                                            CircularProgressIndicator(
                                              color: kPrimary,
                                              value: progress,
                                            ).center(),
                                            Text(
                                              "Uploading Image",
                                              style: primaryTextStyle(size: 13),
                                            ),
                                          ],
                                        )
                                      : StreamBuilder<UserModel>(
                                          stream: userService.getProfile(
                                              userId:
                                                  userController.userId.value),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              var data = snapshot.data;
                                              return profileImage(
                                                  UserModel(), 100, 100,
                                                  context: context);
                                            }
                                            return const CircularProgressIndicator(
                                              color: kPrimary,
                                            ).center();
                                          }),
                                  // Positioned(
                                  //   child: const Icon(
                                  //     Icons.edit,
                                  //     color: kPrimary,
                                  //     size: 14,
                                  //   ).onTap(() {
                                  //     handleChangeImage();
                                  //   }),
                                  // ),
                                ],
                              ).center();
                            },
                          ),
                          10.height,
                          Text(
                            "Your profile isnt complete yet",
                            style: primaryTextStyle(
                              color: coral,
                            ),
                          ).center().visible(!profileCompleted),
                          30.height,
                          Text(
                            "Update Information",
                            style: secondaryTextStyle(
                              size: 14,
                            ),
                          ),
                          10.height,
                          profileOption("Email", data.email.validate(),
                              key: "email"),
                          profileOption("First Name", data.firstName.validate(),
                              key: "firstname"),
                          profileOption("Last Name", data.lastName.validate(),
                              key: "lastname"),
                          profileOption(
                              "Phone Number", data.phoneNumber.validate(),
                              key: "phoneNumber"),
                          profileOption(
                              "Date of Birth",
                              data.dob != null
                                  ? formatDateWithoutTime(data.dob!.toDate())
                                  : "",
                              key: "dob"),
                          profileOption("Address", data.address.validate(),
                              key: "address"),
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: kPrimary,
                  ).center();
                }),
          ),
        );
      }),
    );
  }

  profileOption(String title, String description, {required String key}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: boldTextStyle(size: 14),
                ),
                5.height,
                Text(
                  description,
                  style: secondaryTextStyle(size: 12),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          )
        ],
      ),
    ).onTap(() async {
      controller.clear();
      controller.text = description;
      setState(() {});
      if (key == 'dob') {
        var date = await showDatePicker(
            context: context,
            firstDate: DateTime.now().subtract(const Duration(days: 36500)),
            lastDate: DateTime.now());
        if (date != null) {
          var timeStamp = Timestamp.fromDate(date);
          userService.updateProfile(data: {
            "dob": timeStamp,
          }, userId: userController.userId.value);
          return;
        } else {
          toast("Date was not selected");
          return;
        }
      }

      if (key == 'currency') {
        toast("Change you country in order to change you currency");
      }
      if (key == 'address') {
        ChangePickup().launch(context);
      } else {
        showDialog(
          context: context,
          builder: (context) => ProfileUpdateDialog(
            controller: controller,
            keey: key,
            title: title,
          ),
        );
      }
    });
  }
}

class ProfileUpdateDialog extends StatefulWidget {
  final TextEditingController controller;
  final String keey;
  final String title;
  final String? country;

  const ProfileUpdateDialog({
    super.key,
    required this.controller,
    required this.keey,
    required this.title,
    this.country,
  });

  @override
  _ProfileUpdateDialogState createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  String currency = '';

  final countries = [
    {"name": "Nigeria", "currency": "NGN"},
    // {"name": "Ghana", "currency": "GHS"},
    // {"name": "South Africa", "currency": "ZAR"},
    // {"name": "Kenya", "currency": "KES"},
    // {"name": "Egypt", "currency": "EGP"},
    // {"name": "Morocco", "currency": "MAD"},
    // {"name": "Algeria", "currency": "DZD"},
    // {"name": "Tunisia", "currency": "TND"},
    // {"name": "Ethiopia", "currency": "ETB"},
    // {"name": "Tanzania", "currency": "TZS"},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Update  ${widget.title}",
        style: primaryTextStyle(),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
                style: primaryTextStyle(),
                dropdownColor: context.cardColor,
                hint: Text(
                  "Select ${widget.title}",
                  style: secondaryTextStyle(),
                ),
                items: ['Single', 'Married', 'Complicated']
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  widget.controller.text = val.toString();
                }).visible(widget.keey == 'maritalStatus'),
            DropdownButtonFormField(
                style: primaryTextStyle(),
                hint: Text(
                  "Select ${widget.title}",
                  style: secondaryTextStyle(),
                ),
                dropdownColor: context.cardColor,
                items: [
                  'A(positive)',
                  'A(negative)',
                  'B(positive)',
                  'B(negative)',
                  'AB(positive)',
                  'AB(negative)',
                  'O(positive)',
                  'O(negative)',
                ]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  widget.controller.text = val.toString();
                }).visible(widget.keey == 'bloodGroup'),
            DropdownButtonFormField(
                    style: primaryTextStyle(),
                    hint: Text(
                      "Select ${widget.title}",
                      style: secondaryTextStyle(),
                    ),
                    dropdownColor: context.cardColor,
                    items: ['AA', 'AS', 'SS', 'other']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      widget.controller.text = val.toString();
                      setState(() {});
                    })
                .visible(widget.keey == 'genotype' &&
                    widget.controller.text != 'other'),
            DropdownButtonFormField(
                style: primaryTextStyle(),
                hint: Text(
                  "Select ${widget.title}",
                  style: secondaryTextStyle(),
                ),
                dropdownColor: context.cardColor,
                items: countries
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e['name']!,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  widget.controller.text = val!['name'].toString();
                  currency = val['currency'].toString();
                }).visible(widget.keey == 'country'),
            AppTextField(
              controller: widget.controller,
              textFieldType: TextFieldType.OTHER,
            ).visible(
                widget.keey == 'genotype' && widget.controller.text == 'other'),
            AppTextField(
              readOnly: widget.keey == 'email',
              controller: widget.controller,
              textFieldType: widget.keey == 'weight' || widget.keey == 'height'
                  ? TextFieldType.NUMBER
                  : TextFieldType.OTHER,
              decoration: InputDecoration(
                  hintText: widget.keey == 'height'
                      ? "Height value in fts"
                      : widget.keey == 'weight'
                          ? "Weight value in kg"
                          : "",
                  suffixIcon: widget.keey == 'height'
                      ? Text(
                          "fts",
                          style: primaryTextStyle(),
                        )
                      : widget.keey == 'weight'
                          ? Text(
                              "kg",
                              style: primaryTextStyle(),
                            )
                          : null),
            ).visible(
              widget.keey == 'phoneNumber' ||
                  widget.keey == 'height' ||
                  widget.keey == 'weight' ||
                  widget.keey == 'email' ||
                  widget.keey == 'firstname' ||
                  widget.keey == 'lastname',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: fireBrick),
          onPressed: () {
            widget.controller.clear();
            Navigator.pop(context);
          },
          child: Text(
            "Close",
            style: primaryTextStyle(color: white),
          ),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (currency.isNotEmpty) {
                  userController.currency.value = currency;
                  var prefs = await SharedPreferences.getInstance();
                  prefs.setString('currency', currency);
                  userService.updateProfile(data: {
                    widget.keey: widget.controller.text,
                    "currency": currency,
                  }, userId: userController.userId.value);
                  widget.controller.clear();
                  toast("Update Successful");
                  Navigator.pop(context);
                } else {
                  userService.updateProfile(data: {
                    widget.keey: widget.controller.text,
                  }, userId: userController.userId.value);
                  widget.controller.clear();
                  toast("Update Successful");
                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              "Update",
              style: primaryTextStyle(
                color: white,
              ),
            )).visible(widget.keey != 'email')
      ],
    );
  }
}

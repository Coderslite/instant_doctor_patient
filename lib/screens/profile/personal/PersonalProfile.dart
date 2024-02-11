import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/UploadFile.dart';
import 'package:instant_doctor/services/formatDate.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/ProfileImage.dart';
import '../../../main.dart';

class PersonalProfileScreen extends StatefulWidget {
  const PersonalProfileScreen({super.key});

  @override
  State<PersonalProfileScreen> createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfileScreen> {
  var controller = TextEditingController();
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
            await uploadFile(File(file!.path), userController.userId.value);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        bool isDarkMode = settingsController.isDarkMode.value;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<UserModel>(
                stream:
                    userService.getProfile(userId: userController.userId.value),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const BackButton(
                                color: kPrimary,
                              ),
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
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              isUploading
                                  ? CircularProgressIndicator(
                                      color: kPrimary,
                                    ).center()
                                  : StreamBuilder<UserModel>(
                                      stream: userService.getProfile(
                                          userId: userController.userId.value),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          var data = snapshot.data;
                                          return profileImage(data, 100, 100);
                                        }
                                        return CircularProgressIndicator(
                                          color: kPrimary,
                                        ).center();
                                      }),
                              Positioned(
                                child: Icon(
                                  Icons.edit,
                                  color: kPrimary,
                                  size: 14,
                                ).onTap(() {
                                  handleChangeImage();
                                }),
                              ),
                            ],
                          ).center(),
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
                          profileOption(
                              "Phone Number", data.phoneNumber.validate(),
                              key: "phoneNumber"),
                          profileOption(
                              "Date of Birth",
                              data.dob != null
                                  ? formatDateWithoutTime(data.dob!.toDate())
                                  : "",
                              key: "dob"),
                          profileOption(
                              "Marital Status", data.maritalStatus.validate(),
                              key: "maritalStatus"),
                          profileOption("Height", data.height.validate(),
                              key: "height"),
                          profileOption("Weight", data.weight.validate(),
                              key: "weight"),
                          profileOption(
                              "Blood Group", data.bloodGroup.validate(),
                              key: "bloodGroup"),
                          profileOption("Genotype", data.genotype.validate(),
                              key: "genotype"),
                          profileOption("Surgery History/Medical Condition",
                              data.surgicalHistory.validate(),
                              key: "surgicalHistory"),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              )
            ],
          ),
        ),
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
        } else {
          toast("Date was not selected");
        }
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

  const ProfileUpdateDialog(
      {Key? key,
      required this.controller,
      required this.keey,
      required this.title})
      : super(key: key);

  @override
  _ProfileUpdateDialogState createState() => _ProfileUpdateDialogState();
}

class _ProfileUpdateDialogState extends State<ProfileUpdateDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Update Profile",
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
                  'A(negative)' 'B(positive)',
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
            AppTextField(
              controller: widget.controller,
              textFieldType: TextFieldType.OTHER,
            ).visible(
                widget.keey == 'genotype' && widget.controller.text == 'other'),
            AppTextField(
              readOnly: widget.keey == 'email',
              controller: widget.controller,
              textFieldType: TextFieldType.OTHER,
            ).visible(widget.keey == 'phoneNumber' ||
                widget.keey == 'height' ||
                widget.keey == 'weight' ||
                widget.keey == 'email'),
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
                userService.updateProfile(data: {
                  widget.keey: widget.controller.text,
                }, userId: userController.userId.value);
                widget.controller.clear();
                toast("Update Successful");
                Navigator.pop(context);
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

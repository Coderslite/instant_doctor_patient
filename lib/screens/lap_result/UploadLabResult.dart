import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

import '../../controllers/LapResultController.dart';

class UploadLabResult extends StatefulWidget {
  const UploadLabResult({super.key});

  @override
  State<UploadLabResult> createState() => _UploadLabResultState();
}

class _UploadLabResultState extends State<UploadLabResult> {
  LapResultController lapResultController = Get.put(LapResultController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(
                    color: kPrimary,
                  ),
                  Text(
                    "Upload Lap Result",
                    style: boldTextStyle(color: kPrimary),
                  ),
                  const Text("  "),
                ],
              ),
              20.height,
              DottedBorder(
                  borderType: BorderType.RRect,
                  dashPattern: [10, 5],
                  color: kPrimary,
                  radius: const Radius.circular(12),
                  padding: const EdgeInsets.all(6),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Uplod your file here",
                          style: boldTextStyle(size: 20),
                        ),
                        Text(
                          "png,jpg,img,pdf",
                          style: secondaryTextStyle(size: 14),
                        ),
                        5.height,
                        SizedBox(
                          width: 100,
                          child: Image.asset(
                            "assets/images/upload2.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        AppButton(
                          onTap: () {
                            lapResultController.handlePickFile();
                          },
                          text: "Choose File",
                          textColor: white,
                          color: kPrimary,
                        )
                      ],
                    ),
                  )),
              20.height,
              Row(
                children: [
                  Text(
                    "Files",
                    style: boldTextStyle(size: 18),
                  ),
                ],
              ),
              Expanded(
                child: Obx(
                  () => lapResultController.files.isEmpty
                      ? Text(
                          "Opps No Files Yet",
                          style: secondaryTextStyle(color: sandyBrown),
                        )
                      : ListView.builder(
                          itemCount: lapResultController.files.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, index) {
                            File file = lapResultController.files[index];
                            String fileName = basename(file.path);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Image.asset(
                                      'assets/images/file.png',
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      fileName,
                                      style: primaryTextStyle(),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_sharp,
                                        color: redColor,
                                      ),
                                      onPressed: () {
                                        lapResultController
                                            .handleRemoveFile(index);
                                      },
                                    ),
                                  ),
                                  index + 1 == lapResultController.files.length
                                      ? Column(
                                          children: [
                                            10.height,
                                            Row(
                                              children: [
                                                Checkbox(
                                                    value: lapResultController
                                                        .emailCopy.value,
                                                    onChanged: (val) {
                                                      lapResultController
                                                          .emailCopy
                                                          .value = val!;
                                                      setState(() {});
                                                    }),
                                                Text(
                                                  "Send Copy to Email",
                                                  style: primaryTextStyle(),
                                                )
                                              ],
                                            ),
                                          ],
                                        ).visible(
                                          lapResultController.files.isNotEmpty)
                                      : Container()
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
              AppButton(
                onTap: () {},
                width: double.infinity,
                text: "Proceed",
                textColor: white,
                color: kPrimary,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UploadFileController.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

import '../../controllers/LapResultController.dart';

class UploadLabResult extends StatefulWidget {
  final int amount;
  const UploadLabResult({super.key, required this.amount});

  @override
  State<UploadLabResult> createState() => _UploadLabResultState();
}

class _UploadLabResultState extends State<UploadLabResult> {
  LabResultController labResultController = Get.put(LabResultController());
  UploadFileController uploadFileController = Get.put(UploadFileController());

  @override
  void dispose() {
    uploadFileController.progress.value = 0.0;
    labResultController.files.value = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Upload Lab Result",
                    style: boldTextStyle(color: kPrimary),
                  ),
                  const Text("  "),
                ],
              ),
              20.height,
              DottedBorder(
                  borderType: BorderType.RRect,
                  dashPattern: const [10, 5],
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
                            showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return const BDisplay();
                                });
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
              Obx(() {
                var progress = uploadFileController.progress.value;
                return LinearProgressIndicator(
                  value: progress,
                  color: kPrimary,
                  backgroundColor: white,
                );
              }),
              Expanded(
                child: Obx(() {
                  var r = labResultController.emailCopy.value;
                  return labResultController.files.isEmpty
                      ? Text(
                          "Opps No Files Yet",
                          style: secondaryTextStyle(color: sandyBrown),
                        )
                      : ListView.builder(
                          itemCount: labResultController.files.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, index) {
                            var file = labResultController.files[index];
                            String fileName = basename(file['file'].path);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: file['fileType'] == 'Image'
                                        ? Image.file(
                                            File(file['file'].path),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
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
                                        labResultController
                                            .handleRemoveFile(index);
                                      },
                                    ),
                                  ),
                                  index + 1 == labResultController.files.length
                                      ? Column(
                                          children: [
                                            10.height,
                                            Row(
                                              children: [
                                                Checkbox(
                                                    value: labResultController
                                                        .emailCopy.value,
                                                    onChanged: (val) {
                                                      labResultController
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
                                          labResultController.files.isNotEmpty)
                                      : Container()
                                ],
                              ),
                            );
                          },
                        );
                }),
              ),
              Obx(() {
                var isUpload = labResultController.isUpload.value;
                if (isUpload) {
                  return const CircularProgressIndicator(
                    color: kPrimary,
                  ).center();
                } else {
                  return AppButton(
                    onTap: () {
                      labResultController.handleUploadFiles(context,widget.amount);
                    },
                    width: double.infinity,
                    text: "Proceed",
                    textColor: white,
                    color: kPrimary,
                  );
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}

class BDisplay extends StatefulWidget {
  const BDisplay({super.key});

  @override
  State<BDisplay> createState() => _BDisplayState();
}

class _BDisplayState extends State<BDisplay> {
  String fileType = '';
  LabResultController labResultController = Get.put(LabResultController());
  UploadFileController uploadFileController = Get.put(UploadFileController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          20.height,
          Text(
            "Select file type",
            style: boldTextStyle(size: 20),
          ),
          10.height,
          CheckboxListTile(
              title: Text(
                "Image",
                style: primaryTextStyle(),
              ),
              value: fileType == 'Image',
              onChanged: (val) {
                fileType = "Image";
                setState(() {});
              }),
          CheckboxListTile(
              title: Text(
                "Document",
                style: primaryTextStyle(),
              ),
              value: fileType == 'Document',
              onChanged: (val) {
                fileType = "Document";
                setState(() {});
              }),
          AppButton(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            onTap: () {
              if (fileType.isEmptyOrNull) {
                toast("please select file type");
              } else {
                labResultController.handlePickFile(fileType);
              }
            },
            color: kPrimary,
            textColor: white,
            text: "Proceed",
          ),
          20.height,
        ],
      ),
    );
  }
}


import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/controllers/UploadFileController.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../controllers/LapResultController.dart';

class UploadLabResult extends StatefulWidget {
  final int amount;
  const UploadLabResult({super.key, required this.amount});

  @override
  State<UploadLabResult> createState() => _UploadLabResultState();
}

class _UploadLabResultState extends State<UploadLabResult> {
  final LabResultController labResultController =
      Get.put(LabResultController());
  final UploadFileController uploadFileController =
      Get.put(UploadFileController());
  final paymentController = Get.find<PaymentController>();

  @override
  void dispose() {
    uploadFileController.progress.value = 0.0;
    labResultController.files.value = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          "Upload Lab Result",
          style: boldTextStyle(color: kPrimary, size: 20),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Area
            _buildUploadArea(context),
            20.height,

            // Progress Indicator
            Obx(() => _buildUploadProgress()),

            // Files List Title
            Text(
              "Selected Files",
              style: boldTextStyle(size: 18),
            ),
            10.height,

            // Files List
            Expanded(
              child: Obx(() => _buildFilesList()),
            ),

            // Proceed Button
            _buildProceedButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFileTypeBottomSheet(context),
      child: DottedBorder(
        borderType: BorderType.RRect,
        dashPattern: const [10, 5],
        color: kPrimary.withOpacity(0.5),
        radius: const Radius.circular(12),
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kPrimary.withOpacity(0.05),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 50,
                color: kPrimary,
              ),
              10.height,
              Text(
                "Upload your lab results",
                style: boldTextStyle(size: 18, color: kPrimary),
              ),
              5.height,
              Text(
                "Supported formats: PNG, JPG, PDF",
                style: secondaryTextStyle(size: 14),
              ),
              10.height,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Select Files",
                  style: primaryTextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    final progress = uploadFileController.progress.value;
    return Column(
      children: [
        if (progress > 0 && progress < 1)
          LinearProgressIndicator(
            value: progress,
            color: kPrimary,
            backgroundColor: Colors.grey[200],
            minHeight: 6,
          ),
        if (progress > 0 && progress < 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "${(progress * 100).toStringAsFixed(1)}%",
              style: secondaryTextStyle(size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildFilesList() {
    if (labResultController.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 50,
              color: Colors.grey[400],
            ),
            10.height,
            Text(
              "No files selected yet",
              style: secondaryTextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: labResultController.files.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final file = labResultController.files[index];
        final fileName = basename(file['file'].path);
        final isImage = file['fileType'] == 'Image';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  isImage ? Icons.image : Icons.picture_as_pdf,
                  color: kPrimary,
                ),
              ),
            ),
            title: Text(
              fileName,
              style: primaryTextStyle(),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              file['fileType'],
              style: secondaryTextStyle(size: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => labResultController.handleRemoveFile(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Obx(() {
      if (labResultController.isUpload.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const CircularProgressIndicator(
            color: kPrimary,
          ).center(),
        );
      }

      return Column(
        children: [
          if (labResultController.files.isNotEmpty)
            Row(
              children: [
                Checkbox(
                  value: labResultController.emailCopy.value,
                  onChanged: (val) =>
                      labResultController.emailCopy.value = val!,
                  activeColor: kPrimary,
                ),
                Text(
                  "Send a copy to my email",
                  style: primaryTextStyle(),
                ),
              ],
            ),
          AppButton(
            onTap: () => _handleProceed(context),
            width: double.infinity,
            text: "PROCEED TO PAYMENT",
            textColor: Colors.white,
            color: kPrimary,
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ],
      );
    });
  }

  void _showFileTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FileTypeSelectionSheet(),
    );
  }

  Future<void> _handleProceed(BuildContext context) async {
    if (labResultController.files.isEmpty) {
      toast("Please select at least one file");
      return;
    }

    final user =
        await userService.getProfileById(userId: userController.userId.value);
    final email = user.email.validate();

    paymentController.makePayment(
      email: email,
      context: context,
      amount: widget.amount,
      paymentFor: PaymentFor.labResult,
    );
  }
}

class _FileTypeSelectionSheet extends StatefulWidget {
  @override
  State<_FileTypeSelectionSheet> createState() =>
      __FileTypeSelectionSheetState();
}

class __FileTypeSelectionSheetState extends State<_FileTypeSelectionSheet> {
  String? selectedFileType;
  final LabResultController labResultController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          20.height,
          Text(
            "Select File Type",
            style: boldTextStyle(size: 18),
          ),
          20.height,
          _buildFileTypeOption(
            icon: FontAwesomeIcons.image,
            title: "Image",
            subtitle: "PNG, JPG formats",
            value: "Image",
            context: context,
          ),
          15.height,
          _buildFileTypeOption(
            icon: FontAwesomeIcons.filePdf,
            title: "Document",
            subtitle: "PDF format",
            value: "Document",
            context: context,
          ),
          30.height,
          AppButton(
            width: double.infinity,
            onTap: () {
              if (selectedFileType == null) {
                toast("Please select file type");
                return;
              }
              labResultController.handlePickFile(selectedFileType!);
              Navigator.pop(context);
            },
            color: kPrimary,
            textColor: Colors.white,
            text: "SELECT FILES",
            shapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          10.height,
        ],
      ),
    );
  }

  Widget _buildFileTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () => setState(() => selectedFileType = value),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedFileType == value
              ? kPrimary.withOpacity(0.1)
              : context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selectedFileType == value ? kPrimary : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimary, size: 24),
            15.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: boldTextStyle()),
                4.height,
                Text(subtitle, style: secondaryTextStyle(size: 12)),
              ],
            ),
            const Spacer(),
            if (selectedFileType == value)
              Icon(Icons.check_circle, color: kPrimary),
          ],
        ),
      ),
    );
  }
}

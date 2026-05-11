import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/controllers/UploadFileController.dart';
import 'package:instant_doctor/controllers/showPayment.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../component/PremiumButton.dart';

import '../../controllers/LabResultController.dart';

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
          "Upload Results",
          style: boldTextStyle(color: ink, size: 20, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: pageGray,
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
        dashPattern: const [8, 4],
        color: border,
        strokeWidth: 2,
        radius: const Radius.circular(24),
        padding: const EdgeInsets.all(2),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: obsidian.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: obsidian,
                ),
              ),
              16.height,
              Text(
                "Tap to upload reports",
                style: boldTextStyle(size: 18, color: ink),
              ),
              6.height,
              Text(
                "Supported: PNG, JPG, PDF (Max 10MB)",
                style: secondaryTextStyle(size: 13, color: slate),
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

    return ListView.builder(
      itemCount: labResultController.files.length,
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, index) {
        final file = labResultController.files[index];
        final fileName = basename(file['file'].path);
        final isImage = file['fileType'] == 'Image';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: obsidian.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
                  color: obsidian,
                  size: 24,
                ),
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: boldTextStyle(size: 14, color: ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      file['fileType'],
                      style: secondaryTextStyle(size: 11, color: slate),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: fireBrick, size: 20),
                onPressed: () => labResultController.handleRemoveFile(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Column(
        children: [
          if (labResultController.files.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: labResultController.emailCopy.value,
                      onChanged: (val) => labResultController.emailCopy.value = val!,
                      activeColor: obsidian,
                      side: const BorderSide(color: border, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  12.width,
                  Text(
                    "Send a copy to my email",
                    style: secondaryTextStyle(color: ink, size: 14),
                  ),
                ],
              ),
            ),
          PremiumButton(
            onTap: () => _handleProceed(context),
            text: "Proceed to Payment",
            isLoading: labResultController.isUpload.value,
          ),
          20.height,
        ],
      );
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
    handleShowPaymentOptionLab(context, amount: widget.amount, email: email);
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: white,
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
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          20.height,
          Text(
            "Select File Type",
            style: boldTextStyle(size: 20, color: ink),
          ),
          8.height,
          Text(
            "What kind of document are you uploading?",
            style: secondaryTextStyle(color: slate),
          ),
          24.height,
          _buildFileTypeOption(
            icon: FontAwesomeIcons.image,
            title: "Images",
            subtitle: "PNG, JPG, HEIC formats",
            value: "Image",
            context: context,
          ),
          12.height,
          _buildFileTypeOption(
            icon: FontAwesomeIcons.filePdf,
            title: "Documents",
            subtitle: "PDF, DOCX formats",
            value: "Document",
            context: context,
          ),
          32.height,
          PremiumButton(
            onTap: () {
              if (selectedFileType == null) {
                toast("Please select file type");
                return;
              }
              labResultController.handlePickFile(selectedFileType!);
              Navigator.pop(context);
            },
            text: "Open File Picker",
          ),
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
    bool isSelected = selectedFileType == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFileType = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? obsidian.withOpacity(0.05) : white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? obsidian : border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? obsidian : border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(icon, color: isSelected ? white : slate, size: 18),
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: boldTextStyle(color: isSelected ? obsidian : ink, size: 16)),
                2.height,
                Text(subtitle, style: secondaryTextStyle(size: 12, color: slate)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: obsidian, size: 24),
          ],
        ),
      ),
    );
  }
}

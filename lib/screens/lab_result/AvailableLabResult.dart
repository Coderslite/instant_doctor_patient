import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import '../../component/PremiumButton.dart';
import '../../models/LapResultModel.dart';

class LabResultAvailable extends StatefulWidget {
  final LabResultModel labResult;
  const LabResultAvailable({super.key, required this.labResult});

  @override
  State<LabResultAvailable> createState() => _LabResultAvailableState();
}

class _LabResultAvailableState extends State<LabResultAvailable> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages;
  int? currentPage;
  String errorMessage = '';
  bool isReady = false;
  String url = "";
  bool isDownloading = false;
  double progress = 0.0;

  Future<File> createFileOfPdfUrl() async {
    try {
      var url = widget.labResult.resultUrl.validate();
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      // Check if the file already exists
      if (await file.exists()) {
        print("File already exists");
        return file;
      }

      var request = await http.get(Uri.parse(url));
      var bytes = request.bodyBytes;

      await file.writeAsBytes(bytes, flush: true);
      print("Downloaded file");
      return file;
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
  }

  @override
  void initState() {
    super.initState();
    handleInit();
  }

  handleInit() async {
    await createFileOfPdfUrl().then((f) {
      setState(() {
        url = f.path;
        isReady = true;
      });
    });
  }

  Future<void> downloadFile() async {
    setState(() {
      isDownloading = true;
    });

    try {
      var url = widget.labResult.resultUrl.validate();
      final filename = url.substring(url.lastIndexOf("/") + 1);
      final Directory? downloadsDir =
          await getDownloadsDirectory(); // Get the downloads directory
      File file =
          File("${downloadsDir!.path}/$filename"); // Specify the download path

      if (await file.exists()) {
        toast("File already exists");
        return;
      }

      var request = http.Request('GET', Uri.parse(url));
      var response = await request.send();
      var length = response.contentLength;

      var fileStream = file.openWrite();

      await response.stream.listen(
        (List<int> data) {
          fileStream.add(data);
          setState(() {
            progress += data.length / length!;
          });
        },
        onDone: () async {
          await fileStream.flush();
          await fileStream.close();
          print("Downloaded file");
        },
        onError: (e) {
          throw Exception('Error downloading file: $e');
        },
      ).asFuture();
    } catch (e) {
      print("Download failed: $e");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Report Preview",
                    style: boldTextStyle(size: 20, color: ink, letterSpacing: -0.5),
                  ),
                  GestureDetector(
                    onTap: downloadFile,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: obsidian.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.file_download_outlined, color: obsidian, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isDownloading
                  ? CircularProgressIndicator(
                      value: progress,
                      color: kPrimary,
                    ).center()
                  : isReady
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PDFView(
                              filePath: url,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: false,
                              pageFling: false,
                              // nightMode: settingsController.isDarkMode.value,
                              onRender: (pages) {
                                setState(() {
                                  pages = pages;
                                });
                              },
                              onError: (error) {
                                setState(() {
                                  errorMessage = error.toString();
                                });
                                print(error.toString());
                              },
                              onPageError: (page, error) {
                                setState(() {
                                  errorMessage = '$page: ${error.toString()}';
                                });
                                print('$page: ${error.toString()}');
                              },
                              onViewCreated:
                                  (PDFViewController pdfViewController) {
                                _controller.complete(pdfViewController);
                              },
                              onPageChanged: (int? page, int? total) {
                                setState(() {
                                  currentPage = page;
                                });
                                print('page change: $page/$total');
                              },
                            ),
                            Positioned(
                              bottom: 32,
                              left: 24,
                              right: 24,
                              child: PremiumButton(
                                onTap: downloadFile,
                                text: "Save to Device",
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.file_download, color: white, size: 20),
                                    8.width,
                                    Text("Save to Device", style: boldTextStyle(color: white)),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : const Loader().center(),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (isDownloading)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text("Downloading report...", style: boldTextStyle(size: 14)),
                        const Spacer(),
                        Text("${(progress * 100).toInt()}%", style: boldTextStyle(color: obsidian)),
                      ],
                    ),
                    12.height,
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: border.withOpacity(0.5),
                      color: obsidian,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

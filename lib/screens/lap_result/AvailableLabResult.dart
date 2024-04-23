import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

import '../../models/LapResultModel.dart';

class LabResultAvailable extends StatefulWidget {
  final LabResultModel labResult;
  const LabResultAvailable({Key? key, required this.labResult})
      : super(key: key);

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
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: kPrimary,
                  ),
                  Text(
                    "Lab Result Preview",
                    style: primaryTextStyle(color: kPrimary),
                  ),
                  IconButton(
                    onPressed: () {
                      downloadFile();
                    },
                    icon: Icon(
                      Icons.download,
                      color: kPrimary,
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
                              onRender: (_pages) {
                                setState(() {
                                  pages = _pages;
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
                              bottom: 20,
                              child: AppButton(
                                onTap: () {},
                                text: "Download",
                                color: kPrimary,
                                textColor: white,
                              ),
                            )
                          ],
                        )
                      : CircularProgressIndicator().center(),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            if (isDownloading)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                minHeight: 8,
              ),
          ],
        ),
      ),
    );
  }
}

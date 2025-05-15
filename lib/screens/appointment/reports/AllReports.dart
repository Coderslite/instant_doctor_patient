import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/AppointmentReportModel.dart';
import 'package:instant_doctor/screens/appointment/reports/ReportChat.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/GetUserId.dart';
import '../../../services/ReportService.dart';

class AllReportScreen extends StatefulWidget {
  const AllReportScreen({super.key});

  @override
  State<AllReportScreen> createState() => _AllReportScreenState();
}

class _AllReportScreenState extends State<AllReportScreen> {
  final reportService = Get.find<ReportService>();

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
                    "Reports",
                    style: boldTextStyle(
                      size: 14,
                      color: kPrimary,
                    ),
                  ),
                  const Text("      "),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<AppointmentReportModel>>(
                    stream: reportService.getAllReports(
                        userId: userController.userId.value),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        return data.isEmpty
                            ? Text(
                                "No report yet",
                                style: boldTextStyle(),
                              ).center()
                            : ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  var report = data[index];
                                  return Slidable(
                                    key: ValueKey(report.id.validate()),
                                    startActionPane: ActionPane(
                                      // A motion is a widget used to control how the pane animates.
                                      motion: const ScrollMotion(),

                                      // A pane can dismiss the Slidable.
                                      dismissible: DismissiblePane(
                                          onDismissed: () async {
                                        await reportService.deleteReport(
                                            reportId: report.id.validate());
                                      }),
                                      children: [
                                        SlidableAction(
                                          onPressed: (s) async {
                                            await reportService.deleteReport(
                                                reportId: report.id.validate());
                                          },
                                          backgroundColor:
                                              const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: Card(
                                      color: context.cardColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3.4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    report.id.validate(),
                                                    style: boldTextStyle(
                                                      size: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    timeago
                                                        .format(report
                                                            .updatedAt!
                                                            .toDate())
                                                        .validate(),
                                                    style: secondaryTextStyle(
                                                        size: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 4,
                                                      backgroundColor:
                                                          report.status ==
                                                                  'Answered'
                                                              ? mediumSeaGreen
                                                              : report.status ==
                                                                      'Ongoing'
                                                                  ? fireBrick
                                                                  : grey,
                                                    ),
                                                    3.width,
                                                    Text(
                                                      report.status.validate(),
                                                      style: primaryTextStyle(
                                                          size: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).onTap(() {
                                      ReportChatInterface(
                                        appointmentReport: report,
                                      ).launch(context);
                                    }),
                                  );
                                });
                      }
                      return const CircularProgressIndicator(
                        color: kPrimary,
                      ).center();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

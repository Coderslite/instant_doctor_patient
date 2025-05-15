import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:instant_doctor/models/NotificationModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';

import '../../constant/color.dart';
import '../../constant/constants.dart';
import '../../services/NotificationService.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? previousDate; // To store the date of the previous notification
  final notificationService = Get.find<NotificationService>();

  @override
  void initState() {
    notificationService.updateNotificationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Notification",
                    style: boldTextStyle(size: 25),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: kPrimary,
                        size: 30,
                      ),
                      Positioned(
                        top: -4,
                        right: 0,
                        child: StreamBuilder<List<NotificationModel>>(
                          stream:
                              notificationService.getUserUnSeenNotifications(
                                  userId: userController.userId.value),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var data = snapshot.data;
                              return Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: fireBrick),
                                child: Text(
                                  "${data!.length}",
                                  style: boldTextStyle(color: white, size: 10),
                                ).center(),
                              ).visible(data.isNotEmpty);
                            }
                            return const Text("");
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              30.height,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    return Future.delayed(const Duration(seconds: 2));
                  },
                  child: FutureBuilder<List<NotificationModel>>(
                    future: notificationService.getUserNotifications(
                      userId: userController.userId.value,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        return ListView.builder(
                          itemCount: data!.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            var notification = data[index];
                            DateTime dateTime =
                                notification.createdAt!.toDate();

                            String formattedDate;

                            // Check if the notification date is today
                            if (DateTime.now().day == dateTime.day &&
                                DateTime.now().month == dateTime.month &&
                                DateTime.now().year == dateTime.year) {
                              formattedDate = "Today";
                            } else {
                              // Format DateTime to 'EEE d MMM, yyyy' (e.g., 'Wed 20th, 2024')
                              formattedDate = DateFormat('EEE d MMM, yyyy')
                                  .format(dateTime);
                            }

                            // Show date if it's different from the previous notification date
                            bool showDateHeader = formattedDate != previousDate;

                            // Update the previousDate variable
                            previousDate = formattedDate;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(
                                      formattedDate,
                                      style: boldTextStyle(color: kPrimary),
                                    ),
                                  ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Card(
                                    color: notification.status ==
                                            MessageStatus.read
                                        ? context.cardColor
                                        : context.scaffoldBackgroundColor
                                            .withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.notifications_active,
                                            size: 25,
                                          ),
                                          10.width,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notification.title.validate(),
                                                  style: primaryTextStyle(
                                                      size: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return Loader().center();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

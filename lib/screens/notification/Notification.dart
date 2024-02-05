import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/NotificationModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

// ... (import statements)

class _NotificationScreenState extends State<NotificationScreen> {
  String? previousDate; // Variable to store the previous notification date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    "Notification",
                    style: boldTextStyle(size: 25),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: kPrimary,
                        size: 30,
                      ).onTap(() {
                        const NotificationScreen().launch(context);
                      }),
                      Positioned(
                          top: -4,
                          right: 0,
                          child: StreamBuilder<List<NotificationModel>>(
                              stream: notificationService
                                  .getUserUnSeenNotifications(
                                      userId: userController.userId.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var data = snapshot.data;
                                  return Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: fireBrick),
                                    child: Text(
                                      "${data!.length}",
                                      style:
                                          boldTextStyle(color: white, size: 10),
                                    ).center(),
                                  ).visible(data.isNotEmpty);
                                }
                                return const Text("");
                              }))
                    ],
                  )
                ],
              ),
              30.height,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    return Future.delayed(const Duration(seconds: 2));
                  },
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: notificationService.getUserNotifications(
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
                              // Format DateTime to a string (you can customize the format)
                              formattedDate =
                                  DateFormat('yyyy-MM-dd').format(dateTime);
                            }

                            // Check if the current notification has the same date as the previous one
                            if (formattedDate == previousDate) {
                              formattedDate =
                                  ""; // Empty string to not show the date
                            }

                            // Update the previousDate variable for the next iteration
                            previousDate = formattedDate;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (formattedDate
                                    .isNotEmpty) // Show the date only if it's not empty
                                  Text(
                                    formattedDate,
                                    style: boldTextStyle(color: kPrimary),
                                  ),
                                10.height,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Card(
                                    color: notification.status ==
                                            MessageStatus.read
                                        ? null
                                        : context.scaffoldBackgroundColor
                                            .withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Image.asset(
                                              "assets/images/doc1.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          10.width,
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  notification.title.validate(),
                                                  style: primaryTextStyle(
                                                      size: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).onTap(() async {
                                  await notificationService
                                      .updateNotificationStatus(
                                          notificationId: notification.id);
                                  toast("Notification Read");
                                }),
                              ],
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator(
                        color: kPrimary,
                      ).center();
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

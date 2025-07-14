import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/services/ReviewService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constant/color.dart';
import '../models/AppointmentModel.dart';
import 'IsOnline.dart';
import 'TimeRemaining.dart';

Widget eachAppointment({
  required String docId,
  required AppointmentModel appointment,
  required bool isExpired,
  required bool isOngoing,
  required BuildContext context,
}) {
  final date = appointment.createdAt!.toDate();
  final doctorService = Get.find<DoctorService>();
  final appointmentService = Get.find<AppointmentService>();
  return docId.isEmpty || appointment.isPaid.validate() == false
      ? Card(
          color: context.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset("assets/images/logo.png"),
                ),
                10.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Instant Doctor ${appointment.isTrial.validate() ? '-- Trial' : ''}",
                        style: boldTextStyle(
                          size: 14,
                        ),
                      ),
                      Text(
                        isExpired
                            ? "Expired"
                            : appointment.isPaid.validate() ||
                                    appointment.isTrial.validate()
                                ? "Not Assigned"
                                : "Pending Payment",
                        style: secondaryTextStyle(
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          ),
        )
      : StreamBuilder<UserModel>(
          stream: doctorService.getDoc(docId: docId),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if (snapshot.hasData) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        profileImage(data, 60, 60, context: context),
                        Positioned(
                          child:
                              isOnline(data!.status == ONLINE ? true : false),
                        )
                      ],
                    ),
                    5.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${data.firstName!} ${data.lastName!} ${appointment.isTrial.validate() ? '-- Trial' : ''}",
                            style: boldTextStyle(
                              size: 14,
                            ),
                          ),
                          Text(
                            data.speciality!,
                            style: secondaryTextStyle(
                              size: 10,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timelapse,
                                    size: 12,
                                    color: dimGray,
                                  ),
                                  5.width,
                                  Text(
                                    timeago.format(date),
                                    style: secondaryTextStyle(size: 10),
                                  ),
                                ],
                              ),
                              appointment.isPaid.validate() == false &&
                                      !isExpired
                                  ? Text(
                                      "Pending Payment",
                                      style: boldTextStyle(
                                          color: fireBrick, size: 10),
                                    )
                                  : TimeRemaining(
                                      appointment: appointment,
                                    )
                            ],
                          ),
                          AddReviewButton(
                            appointment: appointment,
                            isOngoing: isOngoing,
                            isExpired: isExpired,
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        StreamBuilder<List<AppointmentConversationModel>>(
                            stream: appointmentService.getUnreadChat(
                                appointment.id.validate(), docId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data!.length;
                                if (data < 1) {
                                  return const Text("");
                                }
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle, color: kPrimary),
                                  child: Text(
                                    "$data",
                                    style: boldTextStyle(color: white),
                                  ),
                                );
                              }
                              return const Text("");
                            }),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const Text("");
          });
}

class AddReviewButton extends StatefulWidget {
  final AppointmentModel appointment;
  final bool isExpired;
  final bool isOngoing;
  const AddReviewButton(
      {super.key,
      required this.appointment,
      required this.isExpired,
      required this.isOngoing});

  @override
  State<AddReviewButton> createState() => _AddReviewButtonState();
}

class _AddReviewButtonState extends State<AddReviewButton> {
  bool isReviewed = true;
  final reviewService = Get.find<ReviewService>();
  handleCheck() async {
    var res = await reviewService.getAppointmentReview(
        docId: widget.appointment.doctorId.validate(),
        appointmentId: widget.appointment.id.validate());
    if (res != null) {
      isReviewed = true;
      setState(() {});
    }
  }

  @override
  void initState() {
    handleCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Add Review",
          textAlign: TextAlign.right,
          style: primaryTextStyle(color: orange, size: 12),
        ),
      ],
    ).visible(widget.isExpired && !widget.isOngoing && !isReviewed);
  }
}

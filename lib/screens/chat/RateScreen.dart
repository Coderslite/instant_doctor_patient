import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/profile/help/LiveChat.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../models/AppointmentModel.dart';
import '../../models/ReviewsModel.dart';
import '../../services/GetUserId.dart';
import '../../services/ReportService.dart';
import '../../services/ReviewService.dart';
import '../appointment/reports/CreateReport.dart';
import '../appointment/reports/ReportChat.dart';

class Ratescreen extends StatefulWidget {
  final String docId;
  final AppointmentModel appointment;
  final String appointmentId;
  final bool isExpired;
  final bool isReviewed;
  final UserModel doctor;

  const Ratescreen({
    super.key,
    required this.docId,
    required this.appointment,
    required this.appointmentId,
    required this.isExpired,
    required this.isReviewed,
    required this.doctor,
  });

  @override
  State<Ratescreen> createState() => _RatescreenState();
}

class _RatescreenState extends State<Ratescreen> {
  var reviewService = Get.find<ReviewService>();
  var reportService = Get.find<ReportService>();
  int rating = 3;
  var commentController = TextEditingController();
  var sending = false;
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: transparentColor,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 24), // For balance
                        Text(
                          "Rate Your Session",
                          style: boldTextStyle(size: 18, color: kPrimary),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    20.height,
                    Text(
                      "How was your experience with Dr. ${widget.doctor.firstName}?",
                      style: primaryTextStyle(size: 16),
                      textAlign: TextAlign.center,
                    ),
                    20.height,
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      glow: true,
                      glowColor: Colors.amber.withAlpha(60),
                      glowRadius: 20,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 40,
                      itemPadding: EdgeInsets.symmetric(horizontal: 6),
                      itemBuilder: (context, _) => Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          this.rating = rating.toInt();
                        });
                      },
                      unratedColor: Colors.grey[300],
                    ),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.OTHER,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 200,
                      controller: commentController,
                      textStyle: primaryTextStyle(color: textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: "Tell us about your experience...",
                        fillColor: context.scaffoldBackgroundColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                    20.height,
                    SizedBox(
                      width: double.infinity,
                      child: sending
                          ? Loader()
                          : AppButton(
                              color: kPrimary,
                              text: "Submit Review",
                              textStyle: boldTextStyle(color: white),
                              onTap: () async {
                                if (commentController.text.isEmptyOrNull) {
                                  toast("Please add your comments");
                                } else {
                                  sending = true;
                                  setState(() {});
                                  await reviewService.addReview(
                                      review: ReviewsModel(
                                    rating: rating,
                                    review: commentController.text,
                                    doctorId: widget.docId,
                                    appointmentId: widget.appointmentId,
                                    createdAt: Timestamp.now(),
                                    userId: userController.userId.value,
                                  ));
                                  Navigator.pop(context);
                                  successSnackBar(
                                      title: "Thank you for your feedback!");
                                }
                              },
                            ),
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          color: Colors.white,
                          text: "Report an issue",
                          textStyle: boldTextStyle(color: Colors.red),
                          onTap: () async {
                            var res = await reportService.getReport(
                                appointmentId: widget.appointmentId);
                            Navigator.pop(context);
                            if (res != null) {
                              // ReportChatInterface(
                              //   appointmentReport: res,
                              // ).launch(context);
                              LiveChatScreen().launch(context);
                            } else {
                              // CreateReportScreen(
                              //   userId: widget.appointment.userId.validate(),
                              //   doctorId: widget.appointment.doctorId.validate(),
                              //   appointmentId: widget.appointment.id.validate(),
                              // ).launch(context);
                              LiveChatScreen().launch(context);
                            }
                          },
                        ),
                        10.width,
                        AppButton(
                          color: Colors.transparent,
                          elevation: 0,
                          text: "Close",
                          textStyle: boldTextStyle(),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ).visible(!widget.isReviewed),
            ],
          ),
        ),
      ),
    );
  }
}

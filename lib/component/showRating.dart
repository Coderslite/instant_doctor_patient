// // ignore_for_file: use_build_context_synchronously

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../constant/color.dart';
// import '../models/AppointmentModel.dart';
// import '../models/ReviewsModel.dart';
// import '../models/UserModel.dart';
// import '../screens/appointment/reports/CreateReport.dart';
// import '../screens/appointment/reports/ReportChat.dart';
// import '../services/DoctorService.dart';
// import '../services/GetUserId.dart';
// import '../services/ReportService.dart';
// import '../services/ReviewService.dart';

// handleCheckReview(
//     {required BuildContext context,
//     required String appointmentId,
//     required String docId,
//     required AppointmentModel appointment,
//     required bool isExpired}) async {
//   var commentController = TextEditingController();
//   final doctorService = Get.find<DoctorService>();
//   UserModel? doctor;

//   doctor = await userService.getProfileById(userId: docId);

//   bool isReviewed = false;
//   var reviewService = Get.find<ReviewService>();
//   var reportService = Get.find<ReportService>();
//   var res = await reviewService.getAppointmentReview(
//       docId: docId, appointmentId: appointmentId);
//   isReviewed = res != null;
//   if (isExpired) {
//     showAdaptiveDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(),
//                 AnimatedContainer(
//                   duration: Duration(milliseconds: 300),
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: context.cardColor,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: kPrimary.withOpacity(0.2),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(width: 24), // For balance
//                           Text(
//                             "Rate Your Session",
//                             style: boldTextStyle(size: 18, color: kPrimary),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.close, size: 20),
//                             onPressed: () => Navigator.pop(context),
//                             color: Colors.grey,
//                           ),
//                         ],
//                       ),
//                       20.height,
//                       Text(
//                         "How was your experience with Dr. ${doctor?.firstName}?",
//                         style: primaryTextStyle(size: 16),
//                         textAlign: TextAlign.center,
//                       ),
//                       20.height,
//                       RatingBar.builder(
//                         initialRating: 3,
//                         minRating: 1,
//                         glow: true,
//                         glowColor: Colors.amber.withAlpha(60),
//                         glowRadius: 20,
//                         direction: Axis.horizontal,
//                         allowHalfRating: true,
//                         itemCount: 5,
//                         itemSize: 40,
//                         itemPadding: EdgeInsets.symmetric(horizontal: 6),
//                         itemBuilder: (context, _) => Icon(
//                           Icons.star_rounded,
//                           color: Colors.amber,
//                         ),
//                         onRatingUpdate: (rating) {
//                           rating = rating.toInt();
//                         },
//                         unratedColor: Colors.grey[300],
//                       ),
//                       20.height,
//                       AppTextField(
//                         textFieldType: TextFieldType.OTHER,
//                         minLines: 3,
//                         maxLines: 5,
//                         maxLength: 200,
//                         controller: commentController,
//                         textStyle: primaryTextStyle(color: textPrimaryColor),
//                         decoration: InputDecoration(
//                           hintText: "Tell us about your experience...",
//                           fillColor: context.scaffoldBackgroundColor,
//                           filled: true,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: EdgeInsets.all(15),
//                         ),
//                       ),
//                       20.height,
//                       SizedBox(
//                         width: double.infinity,
//                         child: AppButton(
//                           color: kPrimary,
//                           text: "Submit Review",
//                           textStyle: boldTextStyle(color: white),
//                           onTap: () async {
//                             if (commentController.text.isEmptyOrNull) {
//                               toast("Please add your comments");
//                             } else {
//                               await reviewService.addReview(
//                                   review: ReviewsModel(
//                                 rating: rating,
//                                 review: commentController.text,
//                                 doctorId: docId,
//                                 appointmentId: appointmentId,
//                                 createdAt: Timestamp.now(),
//                                 userId: userController.userId.value,
//                               ));
//                               Navigator.pop(context);
//                               toast("Thank you for your feedback!");
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ).visible(!isReviewed),
//                 Column(
//                   children: [
//                     if (isReviewed) ...[
//                       Text(
//                         "Thank you for your feedback!",
//                         style: primaryTextStyle(color: white, size: 16),
//                       ),
//                       20.height,
//                     ],
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         AppButton(
//                           color: Colors.white,
//                           text: "Report Issue",
//                           textStyle: boldTextStyle(color: Colors.red),
//                           onTap: () async {
//                             var res = await reportService.getReport(
//                                 appointmentId: appointmentId);
//                             Navigator.pop(context);
//                             if (res != null) {
//                               ReportChatInterface(
//                                 appointmentReport: res,
//                               ).launch(context);
//                             } else {
//                               CreateReportScreen(
//                                 userId: appointment.userId.validate(),
//                                 doctorId: appointment.doctorId.validate(),
//                                 appointmentId: appointment.id.validate(),
//                               ).launch(context);
//                             }
//                           },
//                         ),
//                         10.width,
//                         AppButton(
//                           color: Colors.transparent,
//                           elevation: 0,
//                           text: "Close",
//                           textStyle: boldTextStyle(color: white),
//                           onTap: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ));
//   }
// }

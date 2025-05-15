// // ignore_for_file: use_build_context_synchronously

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:day_night_time_picker/day_night_time_picker.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
// import 'package:instant_doctor/services/GetUserId.dart';
// import 'package:instant_doctor/services/format_number.dart';
// import 'package:intl/intl.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

// import '../constant/color.dart';
// import '../controllers/BookingController.dart';
// import '../services/formatDate.dart';
// import '../services/formatDuration.dart';
// import '../services/get_weekday.dart';

// class DateBooking2 extends StatefulWidget {
//   final bool panelOpened;
//   final PageController pageController;
//   final String docId;
//   const DateBooking2(
//       {super.key,
//       required this.panelOpened,
//       required this.pageController,
//       required this.docId});

//   @override
//   State<DateBooking2> createState() => _DateBooking2State();
// }

// class _DateBooking2State extends State<DateBooking2> {
//   var bookingController = Get.put(BookingController());

//   String? time;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the available months with the current month
//   }

//   Time _time = Time(hour: 11, minute: 30, second: 20);
//   bool iosStyle = true;

//   bool isClickedSchedule = false;

//   void onTimeChanged(Time newTime) {
//     setState(() {
//       _time = newTime;
//       bookingController.time = newTime;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       physics: widget.panelOpened
//           ? const BouncingScrollPhysics()
//           : const NeverScrollableScrollPhysics(),
//       child: Obx(
//         () => Column(
//           children: [
//             Text(
//               "Please schedule your appointment time",
//               textAlign: TextAlign.center,
//               style: secondaryTextStyle(),
//             ),
//             20.height,
//             Container(
//               decoration: BoxDecoration(
//                 color: context.cardColor,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: dimGray.withOpacity(0.2),
//                     spreadRadius: 2,
//                     blurRadius: 3,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: DropdownButtonFormField(
//                   isExpanded: true,
//                   style: primaryTextStyle(),
//                   dropdownColor: context.cardColor,
//                   value: bookingController.selectedMonth,
//                   decoration: InputDecoration(
//                       hintText: "Select Month",
//                       filled: true,
//                       fillColor: context.cardColor,
//                       hintStyle: secondaryTextStyle(),
//                       border: const OutlineInputBorder(
//                           borderSide: BorderSide.none)),
//                   items: bookingController.availableMonths
//                       .map((e) => DropdownMenuItem(
//                             value: e,
//                             enabled:
//                                 bookingController.availableMonths.indexOf(e) >=
//                                     DateTime.now().month - 1,
//                             child: Text(e),
//                           ))
//                       .toList(),
//                   onChanged: (val) {
//                     setState(() {
//                       bookingController.selectedDate = null;
//                       bookingController.selectedMonth = val;
//                       bookingController.nextTwoWeeks = generateAvailableDates(
//                           bookingController.selectedMonth);
//                     });
//                   }),
//             ),
//             20.height,
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   if (bookingController.selectedMonth != null)
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           for (DateTime date in bookingController.nextTwoWeeks)
//                             Container(
//                               width: 80,
//                               padding: bookingController.selectedDate == date
//                                   ? const EdgeInsets.symmetric(
//                                       vertical: 20, horizontal: 10)
//                                   : const EdgeInsets.all(10),
//                               margin: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: context.cardColor,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: dimGray.withOpacity(0.2),
//                                       spreadRadius: 2,
//                                       blurRadius: 3,
//                                       offset: const Offset(0, 5),
//                                     ),
//                                   ],
//                                   gradient: LinearGradient(
//                                       colors:
//                                           bookingController.selectedDate == date
//                                               ? [kPrimary, kPrimaryLight]
//                                               : [
//                                                   context.cardColor,
//                                                   context.cardColor
//                                                 ])),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     DateFormat('E').format(date),
//                                     style: primaryTextStyle(
//                                         size: 14,
//                                         color: bookingController.selectedDate !=
//                                                 date
//                                             ? kPrimary
//                                             : white),
//                                   ),
//                                   Text(
//                                     DateFormat('dd').format(date),
//                                     style: boldTextStyle(
//                                         size: 26,
//                                         color: bookingController.selectedDate !=
//                                                 date
//                                             ? kPrimary
//                                             : white),
//                                   ),
//                                 ],
//                               ),
//                             ).onTap(() {
//                               bookingController.selectedDate = date;
//                               setState(() {});
//                             })
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               child: TimePickerSpinnerPopUp(
//                 mode: CupertinoDatePickerMode.time,
//                 initTime: DateTime.now(),
//                 onChange: (dateTime) {
//                   // Implement your logic with select dateTime
//                 },
//               ).center(),
//             ),
//             100.height,
//             const CircularProgressIndicator(
//               color: kPrimary,
//             ).center().visible(bookingController.isLoading.value),
//             AppButton(
//               text: bookingController.price > 0
//                   ? "Book Appointment"
//                   : "Select Package",
//               onTap: () async {
//                 if (bookingController.price > 0) {
//                   if (bookingController.selectedDate != null) {
//                     Navigator.of(context)
//                         .push(
//                       await showPicker(
//                         showSecondSelector: false,
//                         context: context,
//                         value: _time,
//                         onChange: onTimeChanged,
//                         minuteInterval: TimePickerInterval.FIVE,
//                       ),
//                     )
//                         .then((value) async {
//                       if (value != null) {
//                         showDialog(
//                             context: context,
//                             barrierDismissible: false,
//                             builder: (context) {
//                               DateTime dateTime = DateTime(
//                                   bookingController.selectedDate!.year,
//                                   bookingController.selectedDate!.month,
//                                   bookingController.selectedDate!.day,
//                                   bookingController.time!.hour,
//                                   bookingController.time!.minute);
//                               var startTime =
//                                   dateTime.difference(DateTime.now());
//                               var now = Timestamp.now();
//                               var isExpired =
//                                   now.compareTo(Timestamp.fromDate(dateTime)) >
//                                       0;
//                               return AlertDialog(
//                                 content: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Appointment Summary",
//                                       style: boldTextStyle(
//                                           size: 20, color: kPrimary),
//                                     ),
//                                     20.height,
//                                     Text(
//                                       "Price:",
//                                       style: primaryTextStyle(size: 14),
//                                     ),
//                                     Text(
//                                       formatAmount(
//                                           bookingController.price.value),
//                                       style: boldTextStyle(size: 16),
//                                     ),
//                                     20.height,
//                                     Text(
//                                       "Start Time:",
//                                       style: primaryTextStyle(size: 14),
//                                     ),
//                                     Text(
//                                       formatDate(dateTime),
//                                       style: boldTextStyle(size: 16),
//                                     ),
//                                     20.height,
//                                     Text(
//                                       "Duration:",
//                                       style: primaryTextStyle(size: 14),
//                                     ),
//                                     Text(
//                                       formatDuration(Duration(
//                                           seconds: bookingController
//                                               .duration.value)),
//                                     ),
//                                     20.height,
//                                     Text(
//                                       "Begins in:",
//                                       style: primaryTextStyle(size: 14),
//                                     ),
//                                     Text(
//                                       isExpired
//                                           ? "Expired"
//                                           : formatDuration(startTime),
//                                       style: boldTextStyle(
//                                           size: 16,
//                                           color: isExpired ? fireBrick : null),
//                                     ),
//                                     20.height,
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         TextButton(
//                                             onPressed: () {
//                                               Navigator.pop(context);
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: fireBrick,
//                                             ),
//                                             child: Text(
//                                               "Cancel",
//                                               style: primaryTextStyle(
//                                                   color: white),
//                                             )),
//                                         TextButton(
//                                                 onPressed: () async {
//                                                   try {
//                                                     Navigator.pop(context);
//                                                     isClickedSchedule = true;
//                                                     setState(() {});
//                                                     await bookingController
//                                                         .handleBookAppointment(
//                                                             docId: widget.docId,
//                                                             userId:
//                                                                 userController
//                                                                     .userId
//                                                                     .value,
//                                                             context: context);
//                                                   } finally {
//                                                     isClickedSchedule = false;
//                                                     setState(() {});
//                                                   }
//                                                 },
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor: kPrimary,
//                                                 ),
//                                                 child: Text(
//                                                   "Proceed",
//                                                   style: primaryTextStyle(),
//                                                 ))
//                                             .visible(!isClickedSchedule &&
//                                                 bookingController.price > 0)
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                               );
//                             });
//                       } else {
//                         toast("time was not selected");
//                       }
//                     });
//                   } else {
//                     toast("please select a fixed date");
//                   }
//                 } else {
//                   const AppointmentPricingScreen(fromDocScreen: true)
//                       .launch(context);
//                 }
//               },
//               color: kPrimary,
//               textColor: white,
//               width: double.infinity,
//             ).visible(!bookingController.isLoading.value),
//             10.height,
//             TextButton(
//               onPressed: () {
//                 widget.pageController.previousPage(
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeOut);
//               },
//               child: Text(
//                 "Go Back",
//                 style: primaryTextStyle(),
//               ),
//             ),
//             TextButton.icon(
//               onPressed: () {
//                 const AppointmentPricingScreen(fromDocScreen: true)
//                     .launch(context);
//               },
//               icon: const Icon(Icons.swap_horiz),
//               label: Text(
//                 "Change Package",
//                 style: primaryTextStyle(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Container timeCard({required String time}) {
//     return Container(
//       padding: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: kPrimary,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: dimGray.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 3,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Text(
//         time,
//         style: primaryTextStyle(color: white, size: 14),
//       ),
//     );
//   }
// }

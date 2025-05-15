
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import '../../component/ProfileImage.dart';
import '../../constant/color.dart';
import '../../controllers/BookingController.dart';
import '../../models/UserModel.dart';
import '../../services/AppointmentService.dart';
import '../../services/GetUserId.dart';
import '../../services/formatDate.dart';
import '../../services/formatDuration.dart';

class NewAppointment extends StatefulWidget {
  final String docID;
  const NewAppointment({super.key, required this.docID});

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  final bookingController = Get.find<BookingController>();
  final appointmentService = Get.find<AppointmentService>();

  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();

  bool isLoading = true;
  List<Appointmentpricingmodel> price = [];
  TimeOfDay? time;
  @override
  void initState() {
    handleGetPrice();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  handleGetPrice() async {
    price = await appointmentService.getAppointmentPrice();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardDismisser(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Text(
                      "Create Appointment",
                      style: boldTextStyle(),
                    ),
                    Text("     "),
                  ],
                ),
                20.height,
                Expanded(
                  child: isLoading
                      ? Loader()
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                color: context.cardColor,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: StreamBuilder<UserModel>(
                                        stream: userService.getProfile(
                                            userId: widget.docID.validate()),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            var userData = snapshot.data!;
                                            return Row(
                                              children: [
                                                profileImage(userData, 50, 50,
                                                    context: context),
                                                10.width,
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${userData.firstName} ${userData.lastName}",
                                                        style: boldTextStyle(
                                                          size: 16,
                                                        ),
                                                      ),
                                                      Text(
                                                        userData.speciality
                                                            .validate(),
                                                        style:
                                                            secondaryTextStyle(
                                                          size: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return Loader();
                                        })),
                              ),
                              10.height,
                              Text(
                                "Select Package",
                                style: boldTextStyle(size: 12),
                              ),
                              Card(
                                color: context.cardColor,
                                child: DropdownButtonFormField(
                                  style: boldTextStyle(),
                                  dropdownColor: context.cardColor,
                                  items: price
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(
                                            "${e.name} ~ ${formatAmount(e.amount.validate())}",
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    var data = val;
                                    bookingController.duration.value =
                                        data!.duration.validate();
                                    bookingController.price.value =
                                        data.amount.validate();
                                    bookingController.package.value =
                                        data.name.validate();
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              20.height,
                              Text(
                                "Enter Complain",
                                style: boldTextStyle(size: 12),
                              ),
                              Card(
                                color: context.cardColor,
                                child: AppTextField(
                                  textFieldType: TextFieldType.MULTILINE,
                                  minLines: 10,
                                  maxLines: 15,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    bookingController.complain.value = val;
                                  },
                                ),
                              ),
                              20.height,
                              Text(
                                "Select Date",
                                style: boldTextStyle(size: 12),
                              ),
                              Card(
                                color: context.cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: EasyInfiniteDateTimeLine(
                                    controller: _controller,
                                    firstDate: DateTime.now(),
                                    showTimelineHeader: false,
                                    dayProps: EasyDayProps(
                                      inactiveDayNumStyle: primaryTextStyle(),
                                      todayNumStyle: primaryTextStyle(),
                                      todayMonthStrStyle: boldTextStyle(),
                                    ),
                                    selectionMode: SelectionMode.alwaysFirst(),
                                    focusDate: bookingController.selectedDate,
                                    lastDate:
                                        DateTime.now().add(Duration(days: 7)),
                                    onDateChange: (selectedDate) {
                                      setState(() {
                                        bookingController.selectedDate =
                                            selectedDate;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              20.height,
                              Text(
                                "Select Time",
                                style: boldTextStyle(size: 12),
                              ),
                              // Card(
                              //   color: context.cardColor,
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(8.0),
                              //     child: TimePickerSpinnerPopUp(
                              //       mode: CupertinoDatePickerMode.time,
                              //       initTime: bookingController.selectedDate,
                              //       textStyle: boldTextStyle(),
                              //       onChange: (dateTime) {
                              //         // Implement your logic with select dateTime
                              //         bookingController.selectedDate = dateTime;
                              //         setState(() {});
                              //       },
                              //     ).center(),
                              //   ),
                              // ),
                              5.height,
                              Container(
                                padding: const EdgeInsets.all(15),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  // border: Border.all(color: kPrimary),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  time == null
                                      ? "Select Appointment Time"
                                      : formatDate(
                                          bookingController.selectedDate),
                                  style: boldTextStyle(),
                                ),
                              ).onTap(() async {
                                time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    // Customizing the theme based on the app's current theme mode
                                    return Theme(
                                      data: settingsController.isDarkMode.value
                                          ? ThemeData.dark().copyWith(
                                              colorScheme: ColorScheme.dark(
                                                primary: kPrimary,
                                                onSurface:
                                                    Colors.white, // Text color
                                              ),
                                              timePickerTheme:
                                                  TimePickerThemeData(
                                                dayPeriodColor: kPrimary,
                                                backgroundColor:
                                                    context.cardColor,
                                                hourMinuteTextColor: white,
                                                dialHandColor: kPrimary,
                                                dialBackgroundColor:
                                                    context.cardColor,
                                              ),
                                            )
                                          : ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: kPrimary,
                                                onSurface:
                                                    Colors.black, // Text color
                                              ),
                                              timePickerTheme:
                                                  TimePickerThemeData(
                                                dayPeriodColor: kPrimary,
                                                backgroundColor:
                                                    context.cardColor,
                                                hourMinuteTextColor: black,
                                                dialHandColor: kPrimary,
                                                dialBackgroundColor:
                                                    context.cardColor,
                                              ),
                                            ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null) {
                                  var d = bookingController.selectedDate;
                                  bookingController.selectedDate = DateTime(
                                      d.year,
                                      d.month,
                                      d.day,
                                      time!.hour,
                                      time!.minute);
                                  setState(() {});
                                } else {
                                  toast("Time not selected");
                                }
                              }),
                              20.height,
                            ],
                          ),
                        ),
                ),
                Obx(
                  () => bookingController.isLoading.value
                      ? Loader()
                      : AppButton(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  var now = Timestamp.now();
                                  var startTime = bookingController.selectedDate
                                      .difference(DateTime.now());
                                  var isExpired = now.compareTo(
                                          Timestamp.fromDate(
                                              bookingController.selectedDate)) >
                                      0;
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Appointment Summary",
                                          style: boldTextStyle(
                                              size: 20, color: kPrimary),
                                        ),
                                        20.height,
                                        Text(
                                          "Price:",
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        Text(
                                          formatAmount(
                                              bookingController.price.value),
                                          style: boldTextStyle(size: 16),
                                        ),
                                        20.height,
                                        Text(
                                          "Start Time:",
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        Text(
                                          formatDate(
                                              bookingController.selectedDate),
                                          style: boldTextStyle(size: 16),
                                        ),
                                        20.height,
                                        Text(
                                          "Duration:",
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        Text(
                                          formatDuration(Duration(
                                              seconds: bookingController
                                                  .duration.value)),
                                          style: boldTextStyle(size: 16),
                                        ),
                                        20.height,
                                        Text(
                                          "Begins in:",
                                          style: primaryTextStyle(size: 14),
                                        ),
                                        Text(
                                          isExpired
                                              ? "Time is behind"
                                              : formatDuration(startTime),
                                          style: boldTextStyle(
                                              size: 16,
                                              color:
                                                  isExpired ? fireBrick : null),
                                        ),
                                        20.height,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: fireBrick,
                                                ),
                                                child: Text(
                                                  "Cancel",
                                                  style: primaryTextStyle(
                                                      color: white),
                                                )),
                                            TextButton(
                                                onPressed: () async {
                                                  try {
                                                    if (time == null) {
                                                      errorSnackBar(
                                                          title:
                                                              "Please select appointment time");
                                                      Navigator.pop(context);

                                                      return;
                                                    }
                                                    Navigator.pop(context);
                                                    setState(() {});
                                                    await bookingController
                                                        .handleBookAppointment(
                                                            doctorId:
                                                                widget.docID,
                                                            context: context);
                                                  } finally {
                                                    setState(() {});
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: kPrimary,
                                                ),
                                                child: Text(
                                                  "Proceed",
                                                  style: primaryTextStyle(),
                                                )),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                          enabled: !isLoading,
                          text: "Proceed",
                          color: kPrimary,
                          textColor: white,
                          width: double.infinity,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

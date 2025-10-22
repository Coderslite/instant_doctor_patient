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
import 'package:badges/badges.dart' as badges;
import '../constant/color.dart';
import '../controllers/SettingController.dart';
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
  // final date = appointment.createdAt!.toDate();
  final doctorService = Get.find<DoctorService>();
  // final appointmentService = Get.find<AppointmentService>();
  // final isDarkMode = Get.find<SettingsController>().isDarkMode.value;

  return Card(
    elevation: 2,
    color: context.cardColor,
    margin: EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: docId.isEmpty || appointment.isPaid.validate() == false
          ? _buildUnassignedAppointment(appointment, isExpired, context)
          : StreamBuilder<UserModel>(
              stream: doctorService.getDoc(docId: docId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return _buildErrorCard();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingCard();
                }
                if (snapshot.hasData) {
                  return _buildDoctorAppointmentCard(snapshot.data!,
                      appointment, isExpired, isOngoing, context);
                }
                return _buildErrorCard();
              },
            ),
    ),
  );
}

Widget _buildUnassignedAppointment(
    AppointmentModel appointment, bool isExpired, BuildContext context) {
  return Row(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(Icons.medical_services, size: 30, color: kPrimary),
        ),
      ),
      12.width,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Instant Doctor ${appointment.isTrial.validate() ? '-- Trial' : ''}",
                  style: boldTextStyle(size: 16),
                ),
                if (isExpired)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Expired",
                      style: secondaryTextStyle(size: 10, color: Colors.red),
                    ),
                  ),
              ],
            ),
            4.height,
            Text(
              isExpired
                  ? "Expired"
                  : appointment.isPaid.validate() ||
                          appointment.isTrial.validate()
                      ? "Waiting for doctor assignment"
                      : "Pending payment",
              style: secondaryTextStyle(size: 12),
            ),
            8.height,
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                4.width,
                Text(
                  timeago.format(appointment.createdAt!.toDate()),
                  style: secondaryTextStyle(size: 12),
                ),
                Spacer(),
                if (!appointment.isPaid.validate() && !isExpired)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Payment Pending",
                      style: secondaryTextStyle(size: 10, color: Colors.orange),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      Icon(Icons.chevron_right, color: Colors.grey),
    ],
  );
}

Widget _buildDoctorAppointmentCard(
    UserModel doctor,
    AppointmentModel appointment,
    bool isExpired,
    bool isOngoing,
    BuildContext context) {
  final date = appointment.createdAt!.toDate();
  final isDarkMode = Get.find<SettingsController>().isDarkMode.value;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Stack(
        alignment: Alignment.bottomRight,
        children: [
          profileImage(doctor, 60, 60, context: context),
          Positioned(
            right: 0,
            bottom: 0,
            child: isOnline(doctor.status == ONLINE ? true : false),
          ),
        ],
      ),
      12.width,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${doctor.firstName!} ${doctor.lastName!} ${appointment.isTrial.validate() ? '-- Trial' : ''}",
                  style: boldTextStyle(size: 16),
                ),
                if (isOngoing)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Ongoing",
                      style: secondaryTextStyle(size: 10, color: Colors.green),
                    ),
                  ),
              ],
            ),
            4.height,
            Text(
              doctor.speciality!,
              style: secondaryTextStyle(size: 12),
            ),
            8.height,
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                4.width,
                Text(
                  timeago.format(date),
                  style: secondaryTextStyle(size: 12),
                ),
                Spacer(),
                TimeRemaining(appointment: appointment),
              ],
            ),
            if (isExpired && !isOngoing)
              AddReviewButton(
                appointment: appointment,
                isOngoing: isOngoing,
                isExpired: isExpired,
              ),
          ],
        ),
      ),
      _buildUnreadMessagesBadge(appointment),
    ],
  );
}

Widget _buildUnreadMessagesBadge(AppointmentModel appointment) {
  final appointmentService = Get.find<AppointmentService>();

  return StreamBuilder<List<AppointmentConversationModel>>(
    stream: appointmentService.getUnreadChat(
        appointment.id.validate(), appointment.doctorId.validate()),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        return badges.Badge(
          badgeContent: Text(
            '${snapshot.data!.length}',
            style: boldTextStyle(size: 10, color: Colors.white),
          ),
          badgeStyle: badges.BadgeStyle(
            badgeColor: kPrimary,
            padding: EdgeInsets.all(6),
          ),
          position: badges.BadgePosition.topEnd(top: -8, end: -8),
          child: Icon(Icons.chevron_right, color: Colors.grey),
        );
      }
      return Icon(Icons.chevron_right, color: Colors.grey);
    },
  );
}

Widget _buildLoadingCard() {
  return Row(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      12.width,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: 120,
              color: Colors.grey.withOpacity(0.2),
            ),
            8.height,
            Container(
              height: 12,
              width: 80,
              color: Colors.grey.withOpacity(0.2),
            ),
            8.height,
            Container(
              height: 12,
              width: 150,
              color: Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildErrorCard() {
  return Row(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(Icons.error_outline, color: Colors.red),
      ),
      12.width,
      Expanded(
        child: Text(
          "Error loading doctor details",
          style: secondaryTextStyle(color: Colors.red),
        ),
      ),
    ],
  );
}

class AddReviewButton extends StatefulWidget {
  final AppointmentModel appointment;
  final bool isExpired;
  final bool isOngoing;
  const AddReviewButton({
    super.key,
    required this.appointment,
    required this.isExpired,
    required this.isOngoing,
  });

  @override
  State<AddReviewButton> createState() => _AddReviewButtonState();
}

class _AddReviewButtonState extends State<AddReviewButton> {
  bool isReviewed = true;
  final reviewService = Get.find<ReviewService>();

  @override
  void initState() {
    super.initState();
    _checkReviewStatus();
  }

  Future<void> _checkReviewStatus() async {
    var res = await reviewService.getAppointmentReview(
      docId: widget.appointment.doctorId.validate(),
      appointmentId: widget.appointment.id.validate(),
    );
    if (res != null) {
      setState(() => isReviewed = true);
    } else {
      setState(() => isReviewed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpired || widget.isOngoing || isReviewed) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: kPrimary),
          4.width,
          Text(
            "Add Review",
            style: secondaryTextStyle(size: 12, color: kPrimary),
          ),
        ],
      ),
    );
  }
}

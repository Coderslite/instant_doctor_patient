import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../constant/color.dart';
import '../models/AppointmentModel.dart';
import '../services/formatDuration.dart';
import 'IsOnline.dart';
import 'TimeRemaining.dart';

Padding eachAppointment(
    {required docId, required AppointmentModel appointment}) {
  var date = appointment.createdAt!.toDate();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: StreamBuilder<UserModel>(
        stream: doctorService.getDoc(docId: docId),
        builder: (context, snapshot) {
          var data = snapshot.data;
          if (snapshot.hasData) {
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: Image.asset(
                            "assets/images/doc1.png",
                            fit: BoxFit.cover,
                          ),
                        ),
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
                            "${data.firstName!} ${data.lastName!}",
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
                              TimeRemaining(
                                appointment: appointment,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Add Review",
                                textAlign: TextAlign.right,
                                style:
                                    primaryTextStyle(color: orange, size: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        StreamBuilder<List<AppointmentConversationModel>>(
                            stream: appointmentService.getUnreadChat(
                                appointment.id!, docId!),
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
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const Text("");
        }),
  );
}

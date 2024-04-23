import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../component/DateBooking.dart';
import '../../component/DateBooking2.dart';
import '../../component/ProfileImage.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  bool panelOpened = false;
  var controller = PanelController();
  var pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: controller,
        isDraggable: false,
        minHeight: MediaQuery.of(context).size.height / 1.5,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: context.cardColor,
        backdropColor: context.cardColor,
        onPanelClosed: () {
          panelOpened = false;
          setState(() {});
        },
        onPanelOpened: () {
          panelOpened = true;
          setState(() {});
        },
        // maxHeight: MediaQuery.of(context).size.height,
        body: Container(
          color: kPrimary,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              10.height,
              Row(
                children: const [
                  BackButton(),
                ],
              ),
              Row(
                children: [
                  profileImage(widget.doctor, 120, 120, context: context),
                  10.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.doctor.firstName} ${widget.doctor.lastName}",
                        style: boldTextStyle(size: 20, color: white),
                      ),
                      Text(
                        widget.doctor.speciality!.validate(),
                        style: secondaryTextStyle(size: 14, color: white),
                      ),
                      5.height,
                      // Container(
                      //   padding: const EdgeInsets.all(5),
                      //   decoration: BoxDecoration(
                      //       color: white,
                      //       borderRadius: BorderRadius.circular(5)),
                      //   child: const Icon(
                      //     Icons.call,
                      //     color: mediumSeaGreen,
                      //     size: 25,
                      //   ).onTap(() {
                      //     const MyCall().launch(context);
                      //   }),
                      // ),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 20, vertical: 20),
            ],
          ),
        ),
        panel: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              30.height,
              Expanded(
                  child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) {},
                children: [
                  DateBooking(
                    pageController: pageController,
                  ),
                  DateBooking2(
                    panelOpened: panelOpened,
                    pageController: pageController,
                    docId: widget.doctor.id!,
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

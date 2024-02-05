import 'package:flutter/material.dart';
import 'package:instant_doctor/component/Call.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../component/DateBooking.dart';
import '../../component/DateBooking2.dart';

class BookAppointmentScreen extends StatefulWidget {
  final UserModel doctor;
  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  List<DateTime?> _dates = [];
  bool panelOpened = false;
  var controller = PanelController();
  var pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        color: Colors.transparent,
        controller: controller,
        onPanelClosed: () {
          panelOpened = false;
          setState(() {});
        },
        onPanelOpened: () {
          panelOpened = true;
          setState(() {});
        },
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: MediaQuery.of(context).size.height - 250,
        body: SafeArea(
          child: Container(
            color: kPrimary,
            child: Column(
              children: [
                Row(
                  children: const [
                    BackButton(),
                  ],
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 90,
                        height: 110,
                        child: Image.asset(
                          "assets/images/doc1.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
        ),
        panel: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
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

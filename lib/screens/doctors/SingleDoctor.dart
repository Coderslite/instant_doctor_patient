import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../models/UserModel.dart';
import '../../services/ReviewService.dart';

class SingleDoctorScreen extends StatefulWidget {
  final UserModel doctor;
  const SingleDoctorScreen({super.key, required this.doctor});

  @override
  State<SingleDoctorScreen> createState() => _SingleDoctorScreenState();
}

class _SingleDoctorScreenState extends State<SingleDoctorScreen> {
  final reviewService = Get.find<ReviewService>();
  bool isOpened = false;
  var controller = PanelController();
  BookingController bookingController = Get.put(BookingController());
  bool isLoading = true;
  int totalReview = 0;

  @override
  void initState() {
    super.initState();
    handleGetTotalReview();
  }

  handleGetTotalReview() async {
    totalReview = await reviewService.getDoctorReviewsCount(
        docId: widget.doctor.id.validate());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (isOpened) {
            setState(() {
              isOpened = false;
              controller.close();
            });
            return false;
          }
          return true;
        },
        child: Stack(
          children: [
            // Background with doctor image
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kPrimary.withOpacity(0.9),
                    kPrimary.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            SlidingUpPanel(
              controller: controller,
              minHeight: MediaQuery.of(context).size.height * 0.35,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              color: context.cardColor,
              backdropEnabled: true,
              parallaxEnabled: true,
              onPanelClosed: () => setState(() => isOpened = false),
              onPanelOpened: () => setState(() => isOpened = true),
              panelBuilder: (scrollController) =>
                  _buildPanelContent(scrollController),
              body: _buildHeaderContent(),
            ),

            // Floating action button
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                backButton(
                  context,
                ),
                Text(
                  "Doctor Profile",
                  style: boldTextStyle(size: 20, color: Colors.white),
                ),
                const SizedBox(width: 40), // For balance
              ],
            ),
          ),

          // Doctor profile card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      profileImage(widget.doctor, 120, 120, context: context),
                      Positioned(
                        right: 10,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child:
                              Icon(Icons.verified, color: kPrimary, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "${widget.doctor.firstName} ${widget.doctor.lastName}",
                    style: boldTextStyle(size: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.doctor.speciality.validate(),
                    style: secondaryTextStyle(size: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text("4.5", style: boldTextStyle()),
                      const SizedBox(width: 8),
                      Text(
                          "($totalReview ${totalReview == 1 ? 'Review' : 'Reviews'})",
                          style: secondaryTextStyle()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Languages and other info
// In your _buildHeaderContent() or _buildPanelContent() method:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildLanguageChip("English", Icons.language),
                if (widget.doctor.otherLanguage.validate().isNotEmpty)
                  ...widget.doctor.otherLanguage
                      .validate()
                      .split(',') // Split by comma
                      .map((lang) => lang.trim()) // Trim whitespace
                      .where((lang) => lang.isNotEmpty) // Remove empty strings
                      .map((lang) => _buildLanguageChip(
                            lang[0].toUpperCase() +
                                lang.substring(1).toLowerCase(),
                            Icons.language,
                          ))
                      ,
              ],
            ),
          ),

          // Open panel indicator
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up,
                  size: 30,
                ),
                Text("Swipe up for details", style: secondaryTextStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Doctor stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.location_on, "Location",
                    widget.doctor.state.validate()),
                _buildStatItem(Icons.work, "Experience",
                    "${widget.doctor.experience} Years"),
                _buildStatItem(Icons.star, "Rating", "4.5"),
              ],
            ),
            const SizedBox(height: 30),

            // About section
            Text("About Doctor", style: boldTextStyle(size: 18)),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              widget.doctor.bio.validate(),
              style: primaryTextStyle(size: 16, height: 1.5),
            ),
            // const SizedBox(height: 30),

            // // Specializations
            // Text("Specializations", style: boldTextStyle(size: 18)),
            // const SizedBox(height: 10),
            // Divider(color: Colors.grey[300]),
            // const SizedBox(height: 10),
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: [
            //     _buildSpecializationChip("General Practice"),
            //     _buildSpecializationChip(widget.doctor.speciality.validate()),
            //     // Add more specializations as needed
            //   ],
            // ),
            // const SizedBox(height: 30),

            // // Availability
            // Text("Availability", style: boldTextStyle(size: 18)),
            // const SizedBox(height: 10),
            // Divider(color: Colors.grey[300]),
            // const SizedBox(height: 10),
            // _buildAvailabilityItem("Monday - Friday", "9:00 AM - 5:00 PM"),
            // _buildAvailabilityItem("Saturday", "10:00 AM - 2:00 PM"),
            // const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: kPrimary),
      label: Text(text, style: primaryTextStyle(size: 12)),
      backgroundColor: context.cardColor.withOpacity(0.9),
      shape: StadiumBorder(side: BorderSide(color: kPrimary.withOpacity(0.2))),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(title, style: secondaryTextStyle(size: 12)),
        const SizedBox(height: 4),
        Text(value, style: boldTextStyle(size: 16)),
      ],
    );
  }

  Widget _buildSpecializationChip(String text) {
    return Chip(
      label: Text(text, style: secondaryTextStyle()),
      backgroundColor: kPrimary.withOpacity(0.1),
      shape: StadiumBorder(side: BorderSide(color: kPrimary.withOpacity(0.2))),
    );
  }

  Widget _buildAvailabilityItem(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(day, style: primaryTextStyle(size: 16)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(time, style: boldTextStyle(size: 14, color: kPrimary)),
          ),
        ],
      ),
    );
  }
}

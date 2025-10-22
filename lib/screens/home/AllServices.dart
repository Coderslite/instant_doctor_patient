import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/check_country.dart';
import 'package:instant_doctor/component/check_internet.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
import 'package:instant_doctor/screens/lab_result/LabResult.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:nb_utils/nb_utils.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Services", style: boldTextStyle(size: 20)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.cardColor,
        leading: backButton(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              internetCheck(),
              countryCheck(),
              20.height,
              Text("Healthcare Services", style: boldTextStyle(size: 18)),
              15.height,
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildServiceCard(
                    context: context,
                    title: "Book Appointment",
                    description: "Schedule with medical professionals",
                    icon: Icons.calendar_today,
                    color: Colors.blue.shade100,
                    iconColor: Colors.blue,
                    onTap: () => NewAppointment().launch(context),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: "Pharmacies",
                    description: "Order medications nearby",
                    icon: Icons.local_pharmacy,
                    color: Colors.green.shade100,
                    iconColor: Colors.green,
                    onTap: () => PharmaciesScreen().launch(context),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: "Medication Tracker",
                    description: "Never miss your doses",
                    icon: Icons.medical_services,
                    color: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    onTap: () => MedicationTracker().launch(context),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: "Lab Results",
                    description: "Upload & interpret reports",
                    icon: Icons.assignment,
                    color: Colors.purple.shade100,
                    iconColor: Colors.purple,
                    onTap: () => LabResultScreen().launch(context),
                  ),
                  _buildServiceCard(
                    context: context,
                    title: "Health Tips",
                    description: "Learn healthy living",
                    icon: Icons.health_and_safety,
                    color: Colors.teal.shade100,
                    iconColor: Colors.teal,
                    onTap: () => HealthTipsHome().launch(context),
                  ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Emergency Services",
                  //   description: "Immediate medical help",
                  //   icon: Icons.emergency,
                  //   color: Colors.red.shade100,
                  //   iconColor: Colors.red,
                  //   onTap: () {
                  //     // Add emergency services navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Telemedicine",
                  //   description: "Virtual consultations",
                  //   icon: Icons.video_call,
                  //   color: Colors.indigo.shade100,
                  //   iconColor: Colors.indigo,
                  //   onTap: () {
                  //     // Add telemedicine navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Medical Records",
                  //   description: "Access your health history",
                  //   icon: Icons.medical_information,
                  //   color: Colors.amber.shade100,
                  //   iconColor: Colors.amber,
                  //   onTap: () {
                  //     // Add medical records navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Wellness Programs",
                  //   description: "Personalized health plans",
                  //   icon: Icons.self_improvement,
                  //   color: Colors.lightBlue.shade100,
                  //   iconColor: Colors.lightBlue,
                  //   onTap: () {
                  //     // Add wellness programs navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Nutrition Guide",
                  //   description: "Dietary recommendations",
                  //   icon: Icons.restaurant,
                  //   color: Colors.lime.shade100,
                  //   iconColor: Colors.lime,
                  //   onTap: () {
                  //     // Add nutrition guide navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Mental Health",
                  //   description: "Counseling & support",
                  //   icon: Icons.psychology,
                  //   color: Colors.deepPurple.shade100,
                  //   iconColor: Colors.deepPurple,
                  //   onTap: () {
                  //     // Add mental health navigation
                  //   },
                  // ),
                  // _buildServiceCard(
                  //   context: context,
                  //   title: "Fitness Tracking",
                  //   description: "Monitor your activity",
                  //   icon: Icons.directions_run,
                  //   color: Colors.pink.shade100,
                  //   iconColor: Colors.pink,
                  //   onTap: () {
                  //     // Add fitness tracking navigation
                  //   },
                  // ),
                ],
              ),
              30.height,
              // _buildFeaturedServices(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: 2,
      mainAxisCellCount: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: boldTextStyle(size: 14, color: black)),
                  4.height,
                  Text(description,
                      style: secondaryTextStyle(size: 10, color: gray),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedServices(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Featured Services", style: boldTextStyle(size: 18)),
        15.height,
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            children: [
              _buildFeaturedCard(
                context: context,
                title: "24/7 Doctor Support",
                description: "Instant access to doctors anytime",
                image: "assets/images/doctor_support.png",
                color: kPrimary,
                onTap: () {
                  // Add doctor support navigation
                },
              ),
              _buildFeaturedCard(
                context: context,
                title: "Health Checkups",
                description: "Comprehensive health assessments",
                image: "assets/images/health_check.png",
                color: Colors.green,
                onTap: () {
                  // Add health checkups navigation
                },
              ),
              _buildFeaturedCard(
                context: context,
                title: "Vaccination",
                description: "Schedule your immunizations",
                image: "assets/images/vaccination.png",
                color: Colors.blue,
                onTap: () {
                  // Add vaccination navigation
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard({
    required BuildContext context,
    required String title,
    required String description,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: boldTextStyle(size: 16, color: color)),
                  8.height,
                  Text(description,
                      style: secondaryTextStyle(
                          size: 12, color: context.iconColor)),
                  12.height,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("Learn More",
                        style:
                            secondaryTextStyle(size: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),
            Image.asset(image, width: 80, height: 80, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}

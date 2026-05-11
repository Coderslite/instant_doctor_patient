import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AboutScreen extends StatefulWidget {
  final String version;
  const AboutScreen({super.key, required this.version});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  backButton(context),
                  24.width,
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    20.height,
                    // App Logo Placeholder
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Image.asset("assets/images/logo2.png"),
                      ),
                    ),
                    32.height,
                    const Text(
                      "Instant Doctor",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: kText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    8.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Version ${widget.version}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                    48.height,
                    
                    _buildInfoCard(
                      title: "Our Mission",
                      content: "Instant Doctor is a telehealth platform designed to bridge the gap between doctors and patients globally. We empower patients to manage their health journey with ease and confidence.",
                    ),
                    24.height,
                    _buildInfoCard(
                      title: "Key Features",
                      content: "• Professional Consultations\n• Digital Prescriptions\n• Medication Tracker\n• Real-time Health Tips\n• Verified Medical Specialists",
                    ),
                    48.height,
                    Text(
                      "© ${DateTime.now().year} Instant Doctor. All rights reserved.",
                      style: const TextStyle(fontSize: 12, color: kSub, fontWeight: FontWeight.w500),
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          16.height,
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: kSub,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

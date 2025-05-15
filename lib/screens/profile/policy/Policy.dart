import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  // Define a list of policies with title and description
  final List<Map<String, String>> policies = [
    {
      "title": "Privacy Policy",
      "description":
          "This policy describes how we collect, use, and protect your personal information."
    },
    {
      "title": "Terms of Service",
      "description":
          "These are the rules and regulations for using the Instant Doctor app."
    },
    {
      "title": "Cancellation and Refund Policy",
      "description":
          "Learn about how cancellations and refunds work for appointments and subscriptions."
    },
    {
      "title": "Medical Disclaimer",
      "description":
          "The app does not replace professional medical advice. In emergencies, seek immediate assistance."
    },
    {
      "title": "User Consent Policy",
      "description":
          "We obtain your consent to use certain data, particularly health-related information."
    },
    {
      "title": "Cookies Policy",
      "description":
          "This policy explains how cookies are used on our platform and what data they track."
    },
    {
      "title": "Security Policy",
      "description":
          "We take data protection seriously and implement measures to secure your information."
    },
    {
      "title": "Support and Contact Information",
      "description":
          "Reach out to our customer support team for any inquiries or assistance needed."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg3.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(kPrimary, BlendMode.color),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(
                      color: white,
                    ),
                    Text(
                      "Policy",
                      style: boldTextStyle(color: white),
                    ),
                    const Text("   "),
                  ],
                ),
                20.height,
                Expanded(
                  child: ListView.builder(
                    itemCount: policies.length,
                    itemBuilder: (context, index) {
                      final policy = policies[index];
                      return Card(
                        color: context.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy["title"] ?? "",
                                style: boldTextStyle(size: 16),
                              ),
                              Text(
                                policy["description"] ?? "",
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

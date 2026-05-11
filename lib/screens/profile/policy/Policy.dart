import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({super.key});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final List<Map<String, String>> policies = [
    {
      "title": "Privacy Policy",
      "description":
          "This policy describes how we collect, use, and protect your personal information.",
      "icon": "🛡️"
    },
    {
      "title": "Terms of Service",
      "description":
          "These are the rules and regulations for using the Instant Doctor app.",
      "icon": "📜"
    },
    {
      "title": "Cancellation Policy",
      "description":
          "Learn about how cancellations and refunds work for appointments.",
      "icon": "🔄"
    },
    {
      "title": "Medical Disclaimer",
      "description":
          "The app does not replace professional medical advice. Seek help in emergencies.",
      "icon": "⚖️"
    },
    {
      "title": "User Consent",
      "description":
          "How we obtain your consent to use health-related information.",
      "icon": "✍️"
    },
    {
      "title": "Security Policy",
      "description":
          "Data protection measures we implement to secure your information.",
      "icon": "🔒"
    },
  ];

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
                    "Policies",
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                itemCount: policies.length,
                itemBuilder: (context, index) {
                  final policy = policies[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(policy["icon"] ?? "📄",
                            style: const TextStyle(fontSize: 24)),
                        20.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                policy["title"] ?? "",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: kText),
                              ),
                              8.height,
                              Text(
                                policy["description"] ?? "",
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: kSub,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

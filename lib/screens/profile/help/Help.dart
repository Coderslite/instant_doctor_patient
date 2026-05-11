import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/profile/help/LiveChat.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
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
                    "Get Help",
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "How can we help you today?",
                    style: TextStyle(
                        fontSize: 16,
                        color: kSub,
                        fontWeight: FontWeight.w500),
                  ),
                  32.height,
                  _buildHelpOption(
                    title: "Live Chat",
                    description: "Chat with our support agent in real-time",
                    icon: Icons.chat_bubble_outline_rounded,
                    color: kPrimary,
                    onTap: () => const LiveChatScreen().launch(context),
                  ),
                  16.height,
                  _buildHelpOption(
                    title: "Email Support",
                    description: "Send us a message and we'll reply within 24h",
                    icon: Icons.alternate_email_rounded,
                    color: Colors.purple,
                    onTap: () {
                      String? encodeQueryParameters(
                          Map<String, String> params) {
                        return params.entries
                            .map((MapEntry<String, String> e) =>
                                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                            .join('&');
                      }

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'instantdoctorservice@gmail.com',
                        query: encodeQueryParameters(<String, String>{
                          'subject': 'Help Request',
                        }),
                      );
                      launchUrl(emailLaunchUri);
                    },
                  ),
                  16.height,
                  _buildHelpOption(
                    title: "FAQs",
                    description: "Find answers to common questions",
                    icon: Icons.help_outline_rounded,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kText.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              20.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kText),
                    ),
                    4.height,
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: kSub,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: kSub),
            ],
          ),
        ),
      ),
    );
  }
}

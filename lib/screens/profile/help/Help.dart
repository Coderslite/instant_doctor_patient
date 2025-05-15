import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    "Get Help",
                    style: boldTextStyle(),
                  ),
                  const Text("   "),
                ],
              ),
              20.height,
              profileOption("Email", "Send us a mail", () {
                String? encodeQueryParameters(Map<String, String> params) {
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
              }),
              profileOption("Live Chat", "Chat with our agent live", () {
                // HelpScreen().launch(context);
                LiveChatScreen().launch(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect profileOption(
      String title, String description, VoidCallback ontap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: boldTextStyle(size: 14),
                  ),
                  5.height,
                  Text(
                    description,
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              )
            ],
          ),
        ),
      ).onTap(ontap),
    );
  }
}

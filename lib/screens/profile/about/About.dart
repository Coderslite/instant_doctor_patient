import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
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
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg3.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(),
                  Text(
                    "About Us",
                    style: boldTextStyle(),
                  ),
                  Text("   "),
                ],
              ),
              20.height,
              Text(
                "Instant Doctor",
                style: primaryTextStyle(
                  size: 30,
                ),
              ),
              SizedBox(
                width: 200,
                child: Divider(
                  height: 5,
                  color: kPrimary,
                ),
              ),
              Text(
                "Version",
                style: primaryTextStyle(size: 14),
              ),
              Text(
                widget.version,
                style: primaryTextStyle(size: 14),
              ),
              20.height,
              Text(
                "Instant Doctor is a Telehealth app designed to bridge the gap between doctors and patients. With the app, patients can schedule appointments with their preferred doctors online and get prescriptions. Some exciting features in the app include: Free medication tracker. Health Tips Consultation with doctors",
                style: primaryTextStyle(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

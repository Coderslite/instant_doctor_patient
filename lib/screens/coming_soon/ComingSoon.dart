import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:nb_utils/nb_utils.dart';

class ComingSoon extends StatefulWidget {
  const ComingSoon({super.key});

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  backButton(context),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Image.asset("assets/images/coming_soon2.png"),
                    ),
                    Text(
                      "Coming Soon",
                      style: primaryTextStyle(
                        fontFamily: GoogleFonts.satisfy().fontFamily,
                        size: 50,
                      ),
                    )
                  ],
                ).center(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

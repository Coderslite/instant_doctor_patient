import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

import '../../constant/color.dart';

class SuccessSignUp extends StatefulWidget {
  const SuccessSignUp({
    super.key,
  });

  @override
  State<SuccessSignUp> createState() => _SuccessSignUpState();
}

class _SuccessSignUpState extends State<SuccessSignUp> {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Animated Success Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3310B981),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                48.height,
                // Success Text
                const Text(
                  "Registration\nSuccessful!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: kText,
                    height: 1.1,
                    letterSpacing: -1.0,
                  ),
                ),
                16.height,
                const Text(
                  "Your healthcare journey starts here. Welcome to the future of personal medical care.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: kSub,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Continue Button
                PremiumButton(
                  onTap: () {
                    const CreatePinScreen().launch(context, isNewTask: true);
                  },
                  text: "Get Started",
                ),
                20.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

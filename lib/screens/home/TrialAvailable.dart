import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:lottie/lottie.dart';
import '../../component/PremiumButton.dart';

class TrialNotificationModal extends StatelessWidget {
  const TrialNotificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20,
                    child: Lottie.asset(
                      'assets/images/med_doc.json', // Replace with your Lottie file
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "TRIAL AVAILABLE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Free Trial Session!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome to Instant Doctor! Enjoy a free consultation with one of our professional doctors to experience our service.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton(
                          onTap: () {
                            settingsController.trialAvailable.value = false;
                            Navigator.pop(context);
                          },
                          text: "Maybe Later",
                          color: Colors.white,
                          textColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: PremiumButton(
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const NewAppointment());
                          },
                          text: "Book Now",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

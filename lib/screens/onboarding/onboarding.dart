import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/email_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../constant/color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();

  // Updated structure to include images and their corresponding text
  final List<Map<String, String>> onboardingData = [
    {
      'image': "onboarding1.jpg",
      'title': "Find Your Doctor",
      'description': "Book appointments with top-rated doctors near you"
    },
    {
      'image': "onboarding2.jpg",
      'title': "Virtual Consultations",
      'description': "Get medical advice from the comfort of your home"
    },
    {
      'image': "onboarding3.jpg",
      'title': "Instant Prescriptions",
      'description': "Receive digital prescriptions instantly"
    },
    {
      'image': "onboarding4.jpg",
      'title': "Health Tracking",
      'description': "Monitor your health progress with our tools"
    },
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding slides
          PageView.builder(
            controller: controller,
            itemCount: onboardingData.length,
            onPageChanged: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background image
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/${onboardingData[index]['image']}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Dark gradient overlay from bottom
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content overlay with text and controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // Title and description
                  Column(
                    children: [
                      Text(
                        onboardingData[currentIndex]['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        onboardingData[currentIndex]['description']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Page indicator
                  SmoothPageIndicator(
                    controller: controller,
                    count: onboardingData.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: kPrimary,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      dotColor: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Navigation buttons
                  if (currentIndex == onboardingData.length - 1)
                    // Get Started button on last page
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          const EmailScreen().launch(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    // Navigation buttons for other pages
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        TextButton(
                          onPressed: () {
                            const EmailScreen().launch(context);
                          },
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // Next button with icon
                        ElevatedButton(
                          onPressed: () {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            elevation: 0,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Optional: Skip button at top right
          if (currentIndex < onboardingData.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GestureDetector(
                  onTap: () {
                    const EmailScreen().launch(context);
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

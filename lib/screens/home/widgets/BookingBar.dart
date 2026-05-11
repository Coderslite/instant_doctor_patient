import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingBar extends StatelessWidget {
  final Animation<double> pulseAnim;
  final int onlineCount;
  final bool isLoading;

  const BookingBar({
    super.key,
    required this.pulseAnim,
    required this.onlineCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            NewAppointment().launch(context);
          },
          child: AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: obsidian,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: obsidian.withOpacity(0.3 + pulseAnim.value * 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(pulseAnim.value * 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoading ? 'Finding doctors...' : '$onlineCount active specialists',
                          style: secondaryTextStyle(size: 9, color: white.withOpacity(0.4)),
                        ),
                        Text(
                          'Book a Consultation',
                          style: boldTextStyle(size: 14, color: white, letterSpacing: -0.2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

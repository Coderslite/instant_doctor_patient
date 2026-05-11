import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/services/greetings.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeHero extends StatelessWidget {
  final Animation<double> heroSlide;
  final Animation<double> heroFade;
  final Animation<double> pulseAnim;
  final Animation<double> orbAnim;
  final int onlineCount;
  final bool isLoading;

  const HomeHero({
    super.key,
    required this.heroSlide,
    required this.heroFade,
    required this.pulseAnim,
    required this.orbAnim,
    required this.onlineCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return AnimatedBuilder(
      animation: heroFade,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, heroSlide.value),
        child: Opacity(
          opacity: heroFade.value,
          child: Container(
            color: obsidian,
            child: Stack(
              children: [
                // ── Animated Background Orbs ──
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: orbAnim,
                    builder: (_, __) {
                      final v = orbAnim.value;
                      return Stack(children: [
                        Positioned(
                          right: -50 + v * 30,
                          top: -40,
                          child: _Orb(size: 240, color: kPrimary, opacity: 0.08),
                        ),
                        Positioned(
                          left: -30 + v * 20,
                          bottom: 20,
                          child: _Orb(size: 140, color: amber, opacity: 0.05),
                        ),
                      ]);
                    },
                  ),
                ),

                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // ── Header Bar ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: amber.withOpacity(0.4), width: 2),
                              ),
                              child: ClipOval(
                                child: profileImage(UserModel(), 48, 48, context: context),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getGreeting(),
                                    style: secondaryTextStyle(size: 11, color: white.withOpacity(0.4)),
                                  ),
                                  Text(
                                    userController.fullName.value.validate(value: 'Welcome'),
                                    style: boldTextStyle(size: 18, color: white),
                                  ),
                                ],
                              ),
                            ),
                            _NotificationButton(),
                          ],
                        ),
                      ),

                      // ── Main Promo Card ──
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                        child: _HeroCard(
                          pulseAnim: pulseAnim,
                          onlineCount: onlineCount,
                          isLoading: isLoading,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Bridge Curve ──
                      Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: pageGray,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Animation<double> pulseAnim;
  final int onlineCount;
  final bool isLoading;

  const _HeroCard({
    required this.pulseAnim,
    required this.onlineCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [obsidian, charcoal.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: obsidian.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
        border: Border.all(color: white.withOpacity(0.08), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Doctor Image
            Positioned(
              right: -10,
              bottom: -10,
              child: Image.asset(
                'assets/images/cartoon_doc.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LiveIndicator(
                    pulseAnim: pulseAnim,
                    count: onlineCount,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Instant Medical\nConsultation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Talk to a doctor in minutes.',
                    style: secondaryTextStyle(color: white.withOpacity(0.6), size: 13),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => NewAppointment().launch(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: white.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        'Book Now',
                        style: boldTextStyle(color: obsidian, size: 14),
                      ),
                    ),
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

class _LiveIndicator extends StatelessWidget {
  final Animation<double> pulseAnim;
  final int count;
  final bool isLoading;

  const _LiveIndicator({
    required this.pulseAnim,
    required this.count,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: pulseAnim.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: green),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isLoading ? 'Checking...' : '$count Doctors Online',
              style: const TextStyle(color: white, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: white.withOpacity(0.12), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, color: white.withOpacity(0.85), size: 24),
          Positioned(
            top: 12,
            right: 13,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: redText,
                shape: BoxShape.circle,
                border: Border.all(color: obsidian, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Orb({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }
}

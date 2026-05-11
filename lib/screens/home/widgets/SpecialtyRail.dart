import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

class SpecialtyRail extends StatelessWidget {
  final Animation<double> docAnim;

  const SpecialtyRail({
    super.key,
    required this.docAnim,
  });

  @override
  Widget build(BuildContext context) {
    final specialties = [
      _SpecialtyDef(
        'General Health',
        Icons.health_and_safety_rounded,
        const Color(0xFF0EA5E9),
        const Color(0xFFE0F2FE),
      ),
      _SpecialtyDef(
        'Pediatrics',
        Icons.child_care_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      ),
      _SpecialtyDef(
        'Cardiology',
        Icons.favorite_rounded,
        const Color(0xFFEF4444),
        const Color(0xFFFEE2E2),
      ),
      _SpecialtyDef(
        'Mental Health',
        Icons.psychology_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFFF5F3FF),
      ),
      _SpecialtyDef(
        'Dermatology',
        Icons.spa_rounded,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
      ),
      _SpecialtyDef(
        'Gynecology',
        Icons.pregnant_woman_rounded,
        const Color(0xFFEC4899),
        const Color(0xFFFCE7F3),
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        physics: const BouncingScrollPhysics(),
        itemCount: specialties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final delay = i * 0.1;
          return AnimatedBuilder(
            animation: docAnim,
            builder: (_, __) {
              final progress = ((docAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset((1 - progress) * 30, 0),
                child: Opacity(
                  opacity: progress,
                  child: _SpecialtyCard(specialty: specialties[i]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SpecialtyCard extends StatefulWidget {
  final _SpecialtyDef specialty;
  const _SpecialtyCard({required this.specialty});

  @override
  State<_SpecialtyCard> createState() => _SpecialtyCardState();
}

class _SpecialtyCardState extends State<_SpecialtyCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // Navigate to booking with the specialty pre-selected if possible
        // For now, it just opens the universal booking flow
        const NewAppointment().launch(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: obsidian.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.specialty.bg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.specialty.icon,
                  color: widget.specialty.color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.specialty.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: boldTextStyle(size: 11, color: ink, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtyDef {
  final String label;
  final IconData icon;
  final Color color, bg;
  const _SpecialtyDef(this.label, this.icon, this.color, this.bg);
}

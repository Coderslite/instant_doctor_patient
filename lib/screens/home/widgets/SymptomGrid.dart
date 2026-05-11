import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

class _Symptom {
  final String label, emoji;
  const _Symptom(this.label, this.emoji);
}

const _symptoms = [
  _Symptom('Fever', '🌡️'),
  _Symptom('Headache', '🤕'),
  _Symptom('Cough', '😮'),
  _Symptom('Stomach pain', '🫁'),
  _Symptom('Fatigue', '😴'),
  _Symptom('Skin rash', '🔴'),
  _Symptom('Nausea', '🤢'),
  _Symptom('Sore throat', '🗣️'),
];

class SymptomGrid extends StatelessWidget {
  final Animation<double> sxAnim;

  const SymptomGrid({super.key, required this.sxAnim});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_symptoms.length, (i) {
          final s = _symptoms[i];
          final delay = i * 0.05;
          return AnimatedBuilder(
            animation: sxAnim,
            builder: (_, __) {
              final progress = ((sxAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, (1 - progress) * 20),
                child: Opacity(
                  opacity: progress,
                  child: _SymptomChip(symptom: s),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _SymptomChip extends StatefulWidget {
  final _Symptom symptom;
  const _SymptomChip({required this.symptom});

  @override
  State<_SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<_SymptomChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        NewAppointment().launch(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? kPrimary.withOpacity(0.05) : white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _isPressed ? kPrimary.withOpacity(0.3) : border, width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.symptom.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                widget.symptom.label,
                style: boldTextStyle(size: 12, color: _isPressed ? kPrimary : ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

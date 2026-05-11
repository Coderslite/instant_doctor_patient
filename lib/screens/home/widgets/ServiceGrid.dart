import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
import 'package:instant_doctor/screens/lab_result/LabResult.dart';
import 'package:instant_doctor/screens/medication/IntroMedicationTracker.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final svcs = [
      _SvcDef(
        'Lab Results',
        Icons.biotech_rounded,
        const Color(0xFF0EA5E9),
        const Color(0xFFE0F2FE),
        () => const LabResultScreen().launch(context),
      ),
      _SvcDef(
        'Medication',
        Icons.medication_rounded,
        const Color(0xFFF97316),
        const Color(0xFFFFF7ED),
        () => const IntroMedicationTracker().launch(context),
      ),
      _SvcDef(
        'Pharmacy',
        Icons.local_pharmacy_rounded,
        const Color(0xFF8B5CF6),
        const Color(0xFFF5F3FF),
        () => const PharmaciesScreen().launch(context),
      ),
      _SvcDef(
        'Health Tips',
        Icons.tips_and_updates_rounded,
        const Color(0xFF10B981),
        const Color(0xFFECFDF5),
        () => const HealthTipsHome().launch(context),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      itemCount: svcs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (_, i) => _ServiceCard(svc: svcs[i]),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final _SvcDef svc;
  const _ServiceCard({required this.svc});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.svc.tap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: obsidian.withOpacity(0.03), 
                blurRadius: 10, 
                offset: const Offset(0, 4)
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.svc.bg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.svc.color.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(widget.svc.icon, color: widget.svc.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.svc.label,
                      style: boldTextStyle(size: 13, color: ink, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Explore',
                      style: secondaryTextStyle(size: 9, color: slate.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: slate.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SvcDef {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback tap;
  const _SvcDef(this.label, this.icon, this.color, this.bg, this.tap);
}

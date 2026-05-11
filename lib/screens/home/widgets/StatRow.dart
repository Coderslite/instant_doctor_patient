import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class StatRow extends StatelessWidget {
  final List<Animation<double>> statAnims;
  final Animation<double> counterAnim;
  final int onlineCount;

  const StatRow({
    super.key,
    required this.statAnims,
    required this.counterAnim,
    required this.onlineCount,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatDef('0', 'Doctors\nOnline', kPrimary, Icons.people_alt_rounded),
      const _StatDef('<5', 'Min\nResponse', amber, Icons.bolt_rounded),
      const _StatDef('4.9', 'Star\nRating', Color(0xFF818CF8), Icons.star_rounded),
      const _StatDef('24/7', 'Always\nAvailable', Color(0xFFF472B6), Icons.event_available_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: List.generate(stats.length, (i) {
          return AnimatedBuilder(
            animation: statAnims[i],
            builder: (_, __) {
              final v = statAnims[i].value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < stats.length - 1 ? 8 : 0),
                  child: Transform.scale(
                    scale: 0.8 + (v * 0.2),
                    child: Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: _StatCard(
                        stat: stats[i],
                        counterAnim: i == 0 ? counterAnim : null,
                        totalOnline: onlineCount,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatDef stat;
  final Animation<double>? counterAnim;
  final int totalOnline;

  const _StatCard({
    required this.stat,
    this.counterAnim,
    this.totalOnline = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              size: 14,
              color: stat.color,
            ),
          ),
          const SizedBox(height: 10),
          if (counterAnim != null)
            AnimatedBuilder(
              animation: counterAnim!,
              builder: (_, __) {
                final count = (counterAnim!.value * totalOnline).round();
                return Text(
                  '$count',
                  style: boldTextStyle(size: 16, color: ink, letterSpacing: -0.5),
                );
              },
            )
          else
            Text(
              stat.value,
              style: boldTextStyle(size: 16, color: ink, letterSpacing: -0.5),
            ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: secondaryTextStyle(size: 9, color: slate, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StatDef {
  final String value, label;
  final Color color;
  final IconData icon;
  const _StatDef(this.value, this.label, this.color, this.icon);
}

// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/models/OrderModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../constant/color.dart';
import '../services/format_number.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
const _white = Colors.white;
const _ink = Color(0xFF0F2744);
const _slate = Color(0xFF5E7A99);
const _border = Color(0xFFE5EAF4);
const _pageGray = Color(0xFFF0F4FA);
const _green = Color(0xFF10B981);
const _greenSoft = Color(0xFFD1FAE5);
const _amber = Color(0xFFF59E0B);
const _amberSoft = Color(0xFFFEF3C7);
const _orange = Color(0xFFF97316);
const _orangeSoft = Color(0xFFFFF0E5);

// ─── Status helpers ───────────────────────────────────────────────────────────
Color _statusColor(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
      return _amber;
    case 'confirmed':
      return kPrimary;
    case 'delivering':
      return _orange;
    case 'completed':
      return _green;
    default:
      return _slate;
  }
}

Color _statusBg(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
      return _amberSoft;
    case 'confirmed':
      return kPrimary.withOpacity(0.08);
    case 'delivering':
      return _orangeSoft;
    case 'completed':
      return _greenSoft;
    default:
      return const Color(0xFFF1F5F9);
  }
}

IconData _statusIcon(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
      return Icons.hourglass_top_rounded;
    case 'confirmed':
      return Icons.check_circle_outline_rounded;
    case 'delivering':
      return Icons.local_shipping_outlined;
    case 'completed':
      return Icons.done_all_rounded;
    default:
      return Icons.circle_outlined;
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ─────────────────────────────────────────────────────────────────────────────
// Stateful wrapper so we get press-scale animation
// ─────────────────────────────────────────────────────────────────────────────
class _EachOrderWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  const _EachOrderWidget({required this.order, this.onTap});

  @override
  State<_EachOrderWidget> createState() => _EachOrderWidgetState();
}

class _EachOrderWidgetState extends State<_EachOrderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order.status.validate();
    final sColor = _statusColor(status);
    final sBg = _statusBg(status);
    final sIcon = _statusIcon(status);
    final items = order.items.validate();
    final isDone = status.toLowerCase() == 'completed';

    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) {
              _ctrl.forward();
              HapticFeedback.selectionClick();
            },
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap!();
            },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: [
              // ── Status top bar ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                decoration: BoxDecoration(
                  color: sBg,
                  border: Border(bottom: BorderSide(color: _border, width: 1)),
                ),
                child: Row(children: [
                  Icon(sIcon, size: 14, color: sColor),
                  const SizedBox(width: 6),
                  Text(
                    _capitalize(status),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: sColor,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${order.trackingId.validate()}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _slate,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ]),
              ),

              // ── Items ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  children:
                      List.generate(items.length > 3 ? 3 : items.length, (i) {
                    final item = items[i];
                    final isLast =
                        i == (items.length > 3 ? 2 : items.length - 1);
                    return Column(children: [
                      Row(children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(Icons.medication_rounded,
                              color: kPrimary.withOpacity(0.65), size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name'].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _pageGray,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            'x${item['quantity']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _slate,
                            ),
                          ),
                        ),
                      ]),
                      if (!isLast) ...[
                        const SizedBox(height: 8),
                        Divider(height: 1, color: _border, indent: 42),
                        const SizedBox(height: 8),
                      ],
                    ]);
                  }),
                ),
              ),

              // "more items" tag
              if (items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 56, top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '+ ${items.length - 3} more item${items.length - 3 > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _slate.withOpacity(0.65),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // ── Total + CTA ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _border, width: 1)),
                ),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Amount',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: _slate.withOpacity(0.65),
                          )),
                      const SizedBox(height: 2),
                      Text(
                        formatAmount(order.totalAmount.validate()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Track / Receipt button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDone ? _greenSoft : kPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDone
                          ? []
                          : [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        isDone
                            ? Icons.receipt_long_outlined
                            : Icons.location_on_outlined,
                        size: 14,
                        color: isDone ? _green : _white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isDone ? 'View Receipt' : 'Track Order',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDone ? _green : _white,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Public helper function — drop-in replacement ─────────────────────────────
Widget eachOrder(BuildContext context, OrderModel order,
    {VoidCallback? onTap}) {
  return _EachOrderWidget(order: order, onTap: onTap);
}

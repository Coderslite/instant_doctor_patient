import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/services/AppointmentService.dart';
import 'package:instant_doctor/services/formatDuration.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../constant/constants.dart';
import '../../models/AppointmentPricingModel.dart';
import '../../services/GetUserId.dart';

class NewAppointment extends StatefulWidget {
  final String? doctorId;
  final String? symptoms;
  const NewAppointment({super.key, this.doctorId, this.symptoms});
  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment>
    with SingleTickerProviderStateMixin {
  // ── Currency helpers ────────────────────────────────────────────────────────
  bool get _isUsd => userController.currency.value == 'USD';

  int get _pkgPrice => _isUsd ? (_pkg?.dollarAmount ?? 0) : (_pkg?.amount ?? 0);

  final _booking = Get.find<BookingController>();
  final _apptSvc = Get.find<AppointmentService>();
  final _complaint = TextEditingController();

  int _step = 0;
  Appointmentpricingmodel? _pkg;
  DateTime? _date;
  String? _time;
  final Set<String> _selectedSymptoms = {};

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    if (widget.symptoms != null) {
      _selectedSymptoms.add(widget.symptoms.validate());
    }
    if (widget.doctorId != null) {
      _booking.docId.value = widget.doctorId.validate();
    }
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _complaint.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  bool get _canAdvance {
    if (_step == 0) return _pkg != null;
    if (_step == 1) return _date != null && _time != null;
    if (_step == 2) return _complaint.text.trim().isNotEmpty;
    return true;
  }

  String? get _hint {
    if (_canAdvance) return null;
    if (_step == 0) return 'Choose a package to continue';
    if (_step == 1) {
      return _date == null ? 'Pick a date first' : 'Now select a time slot';
    }
    if (_step == 2) return 'Describe your condition to continue';
    return null;
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _next() {
    if (!_canAdvance) return;
    if (_step == 3) {
      _confirm();
      return;
    }
    _animate(() => setState(() => _step++));
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    _animate(() => setState(() => _step--));
  }

  void _animate(VoidCallback fn) => _fadeCtrl.reverse().then((_) {
        fn();
        _fadeCtrl.forward();
      });

  // ── Sync to BookingController ───────────────────────────────────────────────
  void _syncToController() {
    _booking.package.value = _pkg?.name ?? '';
    _booking.price.value = _pkgPrice;
    _booking.duration.value = _pkg?.duration ?? 0;
    _booking.complain.value = _complaint.text.trim();
    _booking.selectedSymptoms.value = _selectedSymptoms.toList();
    if (_date != null && _time != null) {
      final parts = _time!.split(':');
      _booking.selectedDate = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }
  }

  void _confirm() {
    _syncToController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfirmSheet(
        pkg: _pkg!,
        date: _date!,
        time: _time!,
        price: _pkgPrice,
        onConfirm: () async {
          Navigator.pop(context);
          await _booking.handleBookAppointment(
            doctorId: '',
            isTrial: _pkg!.name?.toLowerCase().contains('trial') ?? false,
            isPaystack: userController.currency.value.toLowerCase() == 'ngn',
            context: context,
          );
        },
      ),
    );
  }

  // ─── Root ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(children: [
            _TopBar(step: _step, onBack: _back),
            _ProgressRail(step: _step),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                  physics: const BouncingScrollPhysics(),
                  child: _buildStep(),
                ),
              ),
            ),
            _BottomCta(
              label: _step == 3 ? 'Confirm Booking' : 'Continue',
              enabled: _canAdvance,
              hint: _hint,
              showArrow: _step < 3,
              onTap: _next,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) return _packageStep();
    if (_step == 1) return _scheduleStep();
    if (_step == 2) return _symptomsStep();
    return _reviewStep();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 0 — Package
  // ══════════════════════════════════════════════════════════════════════════
  Widget _packageStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _StepHead(
        title: 'How long do you\nneed with the doctor?',
        sub: 'Pick a package that suits your concern',
      ),
      FutureBuilder<List<Appointmentpricingmodel>>(
        future: _apptSvc.getAppointmentPrice(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return _ErrorTile(
                message: 'Could not load packages. Tap to retry.',
                onTap: () => setState(() {}));
          }
          if (!snap.hasData) return const _PackageShimmer();
          final pkgs = snap.data!;
          return Column(
            children: pkgs
                .map((p) => _PackageRow(
                      pkg: p,
                      isSelected: _pkg?.name == p.name,
                      isUsd: _isUsd, // add this
                      onTap: () => setState(() => _pkg = p),
                    ))
                .toList(),
          );
        },
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Schedule
  // ══════════════════════════════════════════════════════════════════════════
  Widget _scheduleStep() {
    final dates =
        List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _StepHead(
        title: 'When works\nbest for you?',
        sub: 'Choose a date and pick a time slot',
      ),
      const _FieldLabel('Date'),
      const SizedBox(height: 10),
      SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = dates[i];
            final isSel = _date != null &&
                d.day == _date!.day &&
                d.month == _date!.month &&
                d.year == _date!.year;
            return _DateChip(
              date: d,
              isToday: i == 0,
              isSelected: isSel,
              onTap: () => setState(() {
                _date = d;
                _time = null;
              }),
            );
          },
        ),
      ),
      const SizedBox(height: 24),
      if (_date == null)
        const _NudgeTile(
            text: 'Select a date above to see available time slots')
      else ...[
        Row(children: [
          const _FieldLabel('Time'),
          const SizedBox(width: 8),
          Text(
            '${dayNames[_date!.weekday % 7]}, ${monthNames[_date!.month - 1]} ${_date!.day}',
            style: TextStyle(
                fontSize: 12, color: kPrimary, fontWeight: FontWeight.w600),
          ),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots
              .map((t) => _TimeChip(
                    time: t,
                    isSelected: _time == t,
                    onTap: () => setState(() => _time = t),
                  ))
              .toList(),
        ),
      ],
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Symptoms
  // ══════════════════════════════════════════════════════════════════════════
  Widget _symptomsStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _StepHead(
        title: 'What are you\nexperiencing?',
        sub: 'This helps the doctor prepare for your session',
      ),
      const _FieldLabel('Common symptoms', optional: true),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: symptoms.map((s) {
          final sel = _selectedSymptoms.contains(s.name);
          return GestureDetector(
            onTap: () => setState(() {
              sel
                  ? _selectedSymptoms.remove(s.name)
                  : _selectedSymptoms.add(s.name);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? kPrimary.withOpacity(0.08) : kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: sel ? kPrimary : kBorder,
                  width: sel ? 1.5 : 1.2,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 5),
                Text(s.name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        color: sel ? kPrimary : kSub)),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
      const _FieldLabel('Describe your condition', required: true),
      const SizedBox(height: 4),
      Text('Be specific — e.g. "Fever for 2 days, 38.5°C, mild headache"',
          style: TextStyle(fontSize: 11, color: kSub.withOpacity(0.8))),
      const SizedBox(height: 10),
      AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _complaint.text.isNotEmpty ? kPrimary : kBorder,
            width: _complaint.text.isNotEmpty ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _complaint.text.isNotEmpty
                  ? kPrimary.withOpacity(0.06)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          controller: _complaint,
          maxLines: 5,
          minLines: 3,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: kText, height: 1.55),
          decoration: const InputDecoration(
            hintText: 'Describe what you\'re feeling and for how long...',
            hintStyle: TextStyle(fontSize: 13, color: Color(0xFFADB5C7)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (_complaint.text.isNotEmpty)
          Row(children: [
            const Icon(Icons.check_circle_rounded, size: 13, color: kGreen),
            const SizedBox(width: 4),
            const Text('Looks good!',
                style: TextStyle(
                    fontSize: 11, color: kGreen, fontWeight: FontWeight.w600)),
          ])
        else
          const SizedBox.shrink(),
        Text('${_complaint.text.length} chars',
            style: const TextStyle(fontSize: 11, color: Color(0xFFADB5C7))),
      ]),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Review
  // ══════════════════════════════════════════════════════════════════════════
  Widget _reviewStep() {
    final dateStr = _date != null
        ? '${dayNames[_date!.weekday % 7]}, ${monthNames[_date!.month - 1]} ${_date!.day}'
        : '—';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _StepHead(
        title: 'Almost there! 🎉',
        sub: 'Review your booking details before confirming',
      ),
      _ReviewBlock(children: [
        _ReviewTile(
          icon: Icons.medical_services_rounded,
          iconColor: kPrimary,
          iconBg: kPrimary.withOpacity(0.1),
          label: 'Package',
          value: _pkg?.name ?? '—',
          badge: formatAmount(_pkgPrice),
          badgeColor: kGreen,
        ),
        _kDivLine(),
        _ReviewTile(
          icon: Icons.calendar_today_rounded,
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFF5F3FF),
          label: 'Date',
          value: dateStr,
        ),
        _kDivLine(),
        _ReviewTile(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFEA580C),
          iconBg: const Color(0xFFFFF7ED),
          label: 'Time',
          value: _time ?? '—',
        ),
        _kDivLine(),
        _ReviewTile(
          icon: Icons.timer_rounded,
          iconColor: const Color(0xFF0369A1),
          iconBg: const Color(0xFFEFF6FF),
          label: 'Duration',
          value:
              formatDuration(Duration(seconds: _pkg?.duration?.toInt() ?? 0)) ??
                  '—',
        ),
      ]),
      const SizedBox(height: 12),
      if (_selectedSymptoms.isNotEmpty || _complaint.text.isNotEmpty)
        _ReviewBlock(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: kGreenBg, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.health_and_safety_rounded,
                    size: 16, color: kGreen),
              ),
              const SizedBox(width: 10),
              const Text('Health Details',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
            ]),
          ),
          if (_selectedSymptoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _selectedSymptoms
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: kPrimary,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
          if (_complaint.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Text(_complaint.text,
                  style:
                      const TextStyle(fontSize: 13, color: kSub, height: 1.5)),
            ),
        ]),
      const SizedBox(height: 12),
      // Total
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimary.withOpacity(0.06), kPrimary.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimary.withOpacity(0.15)),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total to pay',
                style: TextStyle(fontSize: 12, color: kSub)),
            const SizedBox(height: 2),
            Text(formatAmount(_pkgPrice),
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: kGreen,
                    letterSpacing: -0.5)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kGreenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGreen.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified_rounded, size: 13, color: kGreen),
              SizedBox(width: 5),
              Text('Secure payment',
                  style: TextStyle(
                      fontSize: 11,
                      color: kGreen,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      ),
    ]);
  }

  Widget _kDivLine() =>
      const Divider(height: 1, indent: 58, color: Color(0xFFF1F5F9));
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _TopBar({required this.step, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCard,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: Color(0xFF475569)),
          ),
        ),
        const Expanded(
          child: Text('Book Appointment',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: kText)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${step + 1} / 4',
              style: TextStyle(
                  fontSize: 12, color: kPrimary, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  final int step;
  const _ProgressRail({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCard,
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
      child: Row(
        children: List.generate(stepLabels.length, (i) {
          final done = i < step;
          final active = i == step;
          return Expanded(
            child: Row(children: [
              Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? kGreen
                        : active
                            ? kPrimary
                            : kBorder,
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: kPrimary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1)
                          ]
                        : [],
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : kSub)),
                  ),
                ),
                const SizedBox(height: 3),
                Text(stepLabels[i],
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        color: active
                            ? kPrimary
                            : done
                                ? kGreen
                                : kSub)),
              ]),
              if (i < stepLabels.length - 1)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      decoration: BoxDecoration(
                        color: done ? kGreen : kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ]),
          );
        }),
      ),
    );
  }
}

class _StepHead extends StatelessWidget {
  final String title, sub;
  const _StepHead({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kText,
                height: 1.2,
                letterSpacing: -0.3)),
        const SizedBox(height: 5),
        Text(sub,
            style: const TextStyle(fontSize: 13, color: kSub, height: 1.4)),
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool optional;
  final bool required;
  const _FieldLabel(this.text, {this.optional = false, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
      if (optional) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('optional',
              style: TextStyle(
                  fontSize: 9, color: kSub, fontWeight: FontWeight.w500)),
        ),
      ],
      if (required) ...[
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20)),
          child: Text('required',
              style: TextStyle(
                  fontSize: 9, color: kPrimary, fontWeight: FontWeight.w600)),
        ),
      ],
    ]);
  }
}

class _PackageRow extends StatelessWidget {
  final Appointmentpricingmodel pkg;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isUsd;
  const _PackageRow(
      {required this.pkg,
      required this.isSelected,
      required this.onTap,
      required this.isUsd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary.withOpacity(0.04) : kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimary : kBorder,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.1),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isSelected
                  ? kPrimary.withOpacity(0.12)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.medical_services_rounded,
                color: isSelected ? kPrimary : kSub, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(pkg.name.toString(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? kPrimary : kText)),
                const SizedBox(height: 3),
                Text(pkg.desc.toString(),
                    style:
                        const TextStyle(fontSize: 12, color: kSub, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.timer_outlined, size: 12, color: kSub),
                  const SizedBox(width: 4),
                  Text(formatDuration(Duration(seconds: pkg.duration!)),
                      style: const TextStyle(
                          fontSize: 11,
                          color: kSub,
                          fontWeight: FontWeight.w500)),
                ]),
              ])),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
                formatAmount(
                    isUsd ? (pkg.dollarAmount ?? 0) : (pkg.amount ?? 0)),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? kPrimary : kText)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? kPrimary : Colors.transparent,
                border: Border.all(
                    color: isSelected ? kPrimary : kBorder, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected, isToday;
  final VoidCallback onTap;
  const _DateChip(
      {required this.date,
      required this.isSelected,
      required this.isToday,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 54,
        height: 78,
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : kCard,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: isSelected ? kPrimary : kBorder, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: kPrimary.withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(dayNames[date.weekday % 7],
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white.withOpacity(0.8) : kSub)),
          const SizedBox(height: 3),
          Text('${date.day}',
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : kText)),
          Text(monthNames[date.month - 1],
              style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white.withOpacity(0.7) : kSub)),
          if (isToday) ...[
            const SizedBox(height: 4),
            Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : kPrimary)),
          ],
        ]),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;
  const _TimeChip(
      {required this.time, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? kPrimary : Colors.transparent, width: 1.5),
        ),
        child: Text(time,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  final List<Widget> children;
  const _ReviewBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value;
  final String? badge;
  final Color? badgeColor;
  const _ReviewTile(
      {required this.icon,
      required this.iconColor,
      required this.iconBg,
      required this.label,
      required this.value,
      this.badge,
      this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: kSub)),
          const SizedBox(height: 1),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
        ])),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (badgeColor ?? kGreen).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge!,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeColor ?? kGreen)),
          ),
      ]),
    );
  }
}

class _NudgeTile extends StatelessWidget {
  final String text;
  const _NudgeTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(Icons.touch_app_rounded, color: kPrimary, size: 17),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: kPrimary,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String message;
  final VoidCallback onTap;
  const _ErrorTile({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w500))),
          const Icon(Icons.refresh_rounded, color: Color(0xFFDC2626), size: 16),
        ]),
      ),
    );
  }
}

class _PackageShimmer extends StatefulWidget {
  const _PackageShimmer();
  @override
  State<_PackageShimmer> createState() => _PackageShimmerState();
}

class _PackageShimmerState extends State<_PackageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = Tween<double>(begin: -2.0, end: 2.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: List.generate(
            3,
            (_) => AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment(_anim.value - 1, 0),
                        end: Alignment(_anim.value + 1, 0),
                        colors: [
                          const Color(0xFFF1F5F9),
                          Colors.white,
                          const Color(0xFFF1F5F9),
                        ],
                      ),
                    ),
                  ),
                )));
  }
}

class _BottomCta extends StatelessWidget {
  final String label;
  final bool enabled, showArrow;
  final String? hint;
  final VoidCallback onTap;
  const _BottomCta(
      {required this.label,
      required this.enabled,
      required this.onTap,
      this.hint,
      this.showArrow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
      decoration: BoxDecoration(
        color: kCard,
        border: const Border(top: BorderSide(color: kBorder, width: 1.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (hint != null) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.info_outline_rounded,
                size: 13, color: kPrimary.withOpacity(0.7)),
            const SizedBox(width: 5),
            Text(hint!,
                style: TextStyle(
                    fontSize: 12,
                    color: kPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: enabled ? null : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4))
                    ]
                  : [],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1)),
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final Appointmentpricingmodel pkg;
  final DateTime date;
  final String time;
  final VoidCallback onConfirm;
  final int price;
  const _ConfirmSheet(
      {required this.pkg,
      required this.date,
      required this.time,
      required this.onConfirm,
      required this.price});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${dayNames[date.weekday % 7]}, ${monthNames[date.month - 1]} ${date.day}';

    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: kBorder, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 22),
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
            child:
                Icon(Icons.event_available_rounded, color: kPrimary, size: 28)),
        const SizedBox(height: 14),
        const Text('Confirm Booking',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: kText)),
        const SizedBox(height: 4),
        const Text('You\'re about to confirm this appointment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kSub)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: Column(children: [
            _SheetRow('Package', pkg.name.toString()),
            const SizedBox(height: 10),
            _SheetRow('Date', dateStr),
            const SizedBox(height: 10),
            _SheetRow('Time', time),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: kBorder),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: kText)),
              Text(formatAmount(price),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kGreen)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Text('Go Back',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kSub))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: const Center(
                    child: Text('Confirm & Pay',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label, value;
  const _SheetRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: kSub)),
      Text(value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
    ]);
  }
}

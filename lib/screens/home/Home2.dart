import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/healthtips/HealthTipsHome.dart';
import 'package:instant_doctor/screens/lab_result/LabResult.dart';
import 'package:instant_doctor/screens/medication/IntroMedicationTracker.dart';
import 'package:instant_doctor/screens/pharmacy/Pharmacies.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../services/greetings.dart';
import '../appointment/NewAppointment.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────
const _obsidian = Color(0xFF0A1628);
const _charcoal = Color(0xFF142035);
const _gold = Color(0xFFE8B86D);
const _pageGray = Color(0xFFF0F3FA);
const _white = Colors.white;
const _ink = Color(0xFF0D1117);
const _slate = Color(0xFF6B7280);
const _border = Color(0xFFE5E9F0);
const _redDot = Color(0xFFFF4D4F);

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

// ─────────────────────────────────────────────────────────────────────────────
class Home2 extends StatefulWidget {
  const Home2({super.key});
  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _pulseCtrl; // live dot breathe
  late final Animation<double> _pulseAnim;

  late final AnimationController _orbCtrl; // floating orbs in hero
  late final Animation<double> _orbAnim;

  late final AnimationController _shimCtrl; // skeleton shimmer
  late final Animation<double> _shimAnim;

  late final AnimationController _heroCtrl; // hero slide-in
  late final Animation<double> _heroSlide;
  late final Animation<double> _heroFade;

  late final AnimationController _statCtrl; // stat cards pop-in
  late final List<Animation<double>> _statAnims;

  late final AnimationController _docCtrl; // doctor cards cascade
  late final Animation<double> _docAnim;

  late final AnimationController _sxCtrl; // symptom chips wave
  late final Animation<double> _sxAnim;

  late final AnimationController _counterCtrl; // counting stat numbers
  late final Animation<double> _counterAnim;

  // ── State ──────────────────────────────────────────────────────────────────
  List<UserModel> doctors = [];
  bool _loading = true;
  int? _tappedSymptom;
  int? _tappedDoctor;

  @override
  void initState() {
    super.initState();

    // Pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Floating orbs
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _orbAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    // Shimmer
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
    _shimAnim = Tween<double>(begin: -2.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimCtrl, curve: Curves.linear));

    // Hero slide-up
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _heroSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
        CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _heroCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));

    // Stat cards — staggered pop
    _statCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _statAnims = List.generate(4, (i) {
      final start = i * 0.15;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _statCtrl,
          curve: Interval(start, (start + 0.4).clamp(0, 1),
              curve: Curves.elasticOut)));
    });

    // Doctor cascade
    _docCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _docAnim = CurvedAnimation(parent: _docCtrl, curve: Curves.easeOutCubic);

    // Symptom wave
    _sxCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _sxAnim = CurvedAnimation(parent: _sxCtrl, curve: Curves.easeOutCubic);

    // Counter animation
    _counterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _counterAnim =
        CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOutCubic);

    // Orchestrate entry sequence
    _heroCtrl.forward().then((_) {
      _statCtrl.forward().then((_) => _counterCtrl.forward());
    });

    _fetchDoctors();
  }

  @override
  void dispose() {
    for (final c in [
      _pulseCtrl,
      _orbCtrl,
      _shimCtrl,
      _heroCtrl,
      _statCtrl,
      _docCtrl,
      _sxCtrl,
      _counterCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    doctors = await Get.find<DoctorService>().getAllDocs();
    if (mounted) {
      setState(() => _loading = false);
      _docCtrl.forward();
      _sxCtrl.forward();
    }
  }

  int get _online => doctors.where((d) => d.isAvailable.validate()).length;

  // ─── ROOT ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _pageGray,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _hero()),
            SliverToBoxAdapter(child: _statRow()),
            SliverToBoxAdapter(
                child: _sectionHead('Our Specialists',
                    sub: 'Tap a doctor to book instantly', action: 'See all')),
            SliverToBoxAdapter(child: _doctorRail()),
            SliverToBoxAdapter(
                child: _sectionHead("What's bothering you?",
                    sub: 'Tap your symptom — we\'ll do the rest')),
            SliverToBoxAdapter(child: _symptomGrid()),
            SliverToBoxAdapter(child: _sectionHead('More Services')),
            SliverToBoxAdapter(child: _serviceCards()),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
        bottomNavigationBar: _bookBar(context),
      ),
    );
  }

  // ─── HERO ──────────────────────────────────────────────────────────────────
  Widget _hero() {
    return AnimatedBuilder(
      animation: _heroCtrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _heroSlide.value),
        child: Opacity(
          opacity: _heroFade.value,
          child: Container(
            color: _obsidian,
            child: Stack(children: [
              // ── Animated orbs — use Positioned.fill so Stack has a size ──
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _orbAnim,
                  builder: (_, __) {
                    final v = _orbAnim.value;
                    return Stack(children: [
                      Positioned(
                        right: -40 + v * 20,
                        top: -40 + v * 15,
                        child: _Orb(
                            size: 260,
                            color: kPrimary,
                            opacity: 0.10 + v * 0.04),
                      ),
                      Positioned(
                        left: -30 + v * 10,
                        bottom: 20 + v * 20,
                        child: _Orb(
                            size: 160, color: _gold, opacity: 0.06 + v * 0.03),
                      ),
                      Positioned(
                        right: 60 + v * 15,
                        bottom: -10 + v * 8,
                        child: _Orb(size: 80, color: kPrimary, opacity: 0.08),
                      ),
                    ]);
                  },
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(children: [
                  // ── Greeting bar ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                    child: Row(children: [
                      // Avatar — gold ring
                      _TapRipple(
                        onTap: () {},
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _gold.withOpacity(0.7), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withOpacity(0.25),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: ClipOval(
                              child: profileImage(UserModel(), 44, 44,
                                  context: context)),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getGreeting(),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _white.withOpacity(0.45),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4)),
                          const SizedBox(height: 2),
                          Text(userController.fullName.value,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _white,
                                  letterSpacing: -0.3)),
                        ],
                      )),
                      // Notification bell
                      _TapRipple(
                        onTap: () {},
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                color: _white.withOpacity(0.12), width: 1),
                          ),
                          child: Stack(children: [
                            Center(
                                child: Icon(Icons.notifications_outlined,
                                    size: 21, color: _white.withOpacity(0.85))),
                            Positioned(
                              top: 9,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _redDot,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: _obsidian, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _redDot.withOpacity(0.5),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),

                  // ── Main hero card ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                    child: _TapRipple(
                      onTap: () => NewAppointment().launch(context),
                      borderRadius: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _charcoal,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: _white.withOpacity(0.07), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(children: [
                            // Left accent bar (animated glow)
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Positioned(
                                left: 0,
                                top: 16,
                                bottom: 16,
                                child: Container(
                                  width: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kPrimary.withOpacity(_pulseAnim.value),
                                        kPrimary.withOpacity(0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kPrimary.withOpacity(
                                            _pulseAnim.value * 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Doctor illustration
                            Positioned(
                              right: 10,
                              bottom: 0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Image.asset(
                                  "assets/images/cartoon_doc.png",
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),

                            // Text content
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(22, 22, 130, 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Live pill
                                  AnimatedBuilder(
                                    animation: _pulseAnim,
                                    builder: (_, __) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 11, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: kPrimary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: kPrimary.withOpacity(0.3),
                                            width: 1),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Opacity(
                                            opacity: _pulseAnim.value,
                                            child: Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: kPrimary),
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            _loading
                                                ? 'Checking...'
                                                : '$_online doctors online',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: kPrimary,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Headline
                                  const Text(
                                      'Private care,\nwhen you\nneed it.',
                                      style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: _white,
                                          height: 1.18,
                                          letterSpacing: -0.7)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Board-certified doctors\nunder 5 minutes.',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: _white.withOpacity(0.4),
                                          height: 1.55)),
                                  const SizedBox(height: 18),

                                  // CTA — animated glow
                                  AnimatedBuilder(
                                    animation: _pulseAnim,
                                    builder: (_, __) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 11),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [kPrimary, kPrimaryDark],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: kPrimary.withOpacity(
                                                0.2 + _pulseAnim.value * 0.25),
                                            blurRadius:
                                                16 + _pulseAnim.value * 6,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Book Now',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: _white,
                                                  letterSpacing: 0.1)),
                                          SizedBox(width: 7),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 15, color: _white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── STAT ROW ──────────────────────────────────────────────────────────────
  Widget _statRow() {
    final stats = [
      _StatDef(_loading ? '0' : '$_online', 'Doctors\nOnline', kPrimary),
      const _StatDef('<5', 'Min\nResponse', _gold),
      const _StatDef('4.9', 'Star\nRating', Color(0xFF818CF8)),
      const _StatDef('24/7', 'Always\nAvailable', Color(0xFFF472B6)),
    ];

    return Transform.translate(
      offset: const Offset(0, -1),
      child: Container(
        decoration: const BoxDecoration(
          color: _pageGray,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(
          children: List.generate(stats.length, (i) {
            return AnimatedBuilder(
              animation: _statAnims[i],
              builder: (_, __) {
                final v = _statAnims[i].value;
                // Expanded must live directly inside Row, not inside Opacity
                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: i < stats.length - 1 ? 9 : 0),
                    child: Transform.scale(
                      scale: 0.6 + (v * 0.4),
                      child: Opacity(
                        opacity: v.clamp(0.0, 1.0),
                        child: _StatCard(
                          stat: stats[i],
                          counterAnim: i == 0 ? _counterAnim : null,
                          totalOnline: _online,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // ─── SECTION HEAD ──────────────────────────────────────────────────────────
  Widget _sectionHead(String title, {String? sub, String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.5)),
              if (sub != null) ...[
                const SizedBox(height: 4),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12.5, color: _slate, height: 1.3)),
              ],
            ],
          )),
          if (action != null)
            GestureDetector(
              onTap: () {},
              child: Row(children: [
                Text(action,
                    style: const TextStyle(
                        fontSize: 13,
                        color: kPrimary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: kPrimary),
              ]),
            ),
        ],
      ),
    );
  }

  // ─── DOCTOR RAIL ───────────────────────────────────────────────────────────
  Widget _doctorRail() {
    if (_loading) {
      return SizedBox(
        height: 214,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => AnimatedBuilder(
            animation: _shimCtrl,
            builder: (_, __) => Container(
              width: 152,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment(_shimAnim.value - 1, 0),
                  end: Alignment(_shimAnim.value + 1, 0),
                  colors: [
                    const Color(0xFFE8EDF5),
                    Colors.white,
                    const Color(0xFFE8EDF5),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (doctors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
        child: _EmptyState(
          icon: Icons.medical_services_outlined,
          label: 'No doctors online right now',
          sub: 'Check back shortly',
        ),
      );
    }

    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
        physics: const BouncingScrollPhysics(),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          // Staggered cascade from left
          final delay = i * 0.12;
          return AnimatedBuilder(
            animation: _docAnim,
            builder: (_, __) {
              final progress =
                  (((_docAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
              final slide = (1 - progress) * 40;
              return Transform.translate(
                offset: Offset(slide, 0),
                child: Opacity(
                  opacity: progress,
                  child: _DoctorCard(
                    doctor: doctors[i],
                    pulse: _pulseAnim,
                    isPressed: _tappedDoctor == i,
                    onTapDown: () => setState(() => _tappedDoctor = i),
                    onTapUp: () {
                      setState(() => _tappedDoctor = null);
                      NewAppointment(doctorId: doctors[i].id).launch(context);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ─── SYMPTOM GRID ──────────────────────────────────────────────────────────
  Widget _symptomGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      child: Wrap(
        spacing: 9,
        runSpacing: 9,
        children: List.generate(_symptoms.length, (i) {
          final s = _symptoms[i];
          final delay = i * 0.08;
          return AnimatedBuilder(
            animation: _sxAnim,
            builder: (_, __) {
              final progress =
                  (((_sxAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0));
              return Transform.translate(
                offset: Offset(0, (1 - progress) * 20),
                child: Opacity(
                  opacity: progress,
                  child: _SymptomChip(
                    symptom: s,
                    isPressed: _tappedSymptom == i,
                    onTapDown: () => setState(() => _tappedSymptom = i),
                    onTapUp: () {
                      setState(() => _tappedSymptom = null);
                      HapticFeedback.lightImpact();
                      NewAppointment().launch(context);
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // ─── SERVICE CARDS ─────────────────────────────────────────────────────────
  Widget _serviceCards() {
    final svcs = [
      _SvcDef('Lab Results', Icons.biotech_outlined, const Color(0xFF0EA5E9),
          const Color(0xFFE0F2FE), () {
        LabResultScreen().launch(context);
      }),
      _SvcDef('Medication', Icons.medication_outlined, const Color(0xFFF97316),
          const Color(0xFFFFF0E5), () {
        IntroMedicationTracker().launch(context);
      }),
      _SvcDef('Pharmacy', Icons.local_pharmacy_outlined,
          const Color(0xFF8B5CF6), const Color(0xFFF3EFFE), () {
        PharmaciesScreen().launch(context);
      }),
      _SvcDef('Health Tips', Icons.tips_and_updates_outlined,
          const Color(0xFF10B981), const Color(0xFFDCFCE7), () {
        HealthTipsHome().launch(context);
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemCount: svcs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1,
        ),
        itemBuilder: (_, i) {
          final s = svcs[i];
          return _TapRipple(
            onTap: svcs[i].tap,
            borderRadius: 18,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border, width: 1),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 10,
                      offset: Offset(0, 3))
                ],
              ),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(s.icon, color: s.color, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.label,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _ink)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text('Open',
                          style: TextStyle(
                              fontSize: 10,
                              color: s.color,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 8, color: s.color),
                    ]),
                  ],
                )),
              ]),
            ),
          );
        },
      ),
    );
  }

  // ─── BOTTOM BOOK BAR ───────────────────────────────────────────────────────
  Widget _bookBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFECEFF4))),
        boxShadow: [
          BoxShadow(
              color: _obsidian.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -8))
        ],
      ),
      child: _TapRipple(
        onTap: () {
          HapticFeedback.mediumImpact();
          NewAppointment().launch(context);
        },
        borderRadius: 16,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
            decoration: BoxDecoration(
              color: _obsidian,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _obsidian.withOpacity(0.3 + _pulseAnim.value * 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(children: [
              // Glowing dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(_pulseAnim.value * 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _loading
                        ? 'Finding doctors...'
                        : '$_online doctors online now',
                    style: TextStyle(
                        fontSize: 10,
                        color: _white.withOpacity(0.4),
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 1),
                  const Text('Book a Consultation',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _white,
                          letterSpacing: -0.2)),
                ],
              )),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: kPrimary, size: 19),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

// ─── Floating orb ─────────────────────────────────────────────────────────────
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
        gradient: RadialGradient(colors: [
          color.withOpacity(opacity),
          Colors.transparent,
        ]),
      ),
    );
  }
}

// ─── Tap ripple wrapper ────────────────────────────────────────────────────────
class _TapRipple extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  const _TapRipple(
      {required this.child, required this.onTap, this.borderRadius = 0});

  @override
  State<_TapRipple> createState() => _TapRippleState();
}

class _TapRippleState extends State<_TapRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ─── Doctor card ──────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final Animation<double> pulse;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  const _DoctorCard(
      {required this.doctor,
      required this.pulse,
      required this.isPressed,
      required this.onTapDown,
      required this.onTapUp});

  @override
  Widget build(BuildContext context) {
    final online = doctor.isAvailable.validate();

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        onTapDown();
      },
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapDown(), // reset
      child: AnimatedScale(
        scale: isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 152,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isPressed ? const Color(0xFFF5F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: online
                  ? kPrimary.withOpacity(isPressed ? 0.5 : 0.25)
                  : _border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: online
                    ? kPrimary.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isPressed ? 4 : 16,
                offset: Offset(0, isPressed ? 1 : 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                // Avatar
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: online ? kPrimary.withOpacity(0.35) : _border,
                        width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: profileImage(doctor, 54, 54, context: context),
                  ),
                ),
                // Status badge
                AnimatedBuilder(
                  animation: pulse,
                  builder: (_, __) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: online
                          ? kPrimary.withOpacity(0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Opacity(
                        opacity: online ? pulse.value : 1.0,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: online ? kPrimary : _slate,
                            boxShadow: online
                                ? [
                                    BoxShadow(
                                      color: kPrimary
                                          .withOpacity(pulse.value * 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(online ? 'Live' : 'Away',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: online ? kPrimary : _slate)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(
                '${doctor.firstName.validate()} ${doctor.lastName.validate()}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    height: 1.2),
              ),
              const SizedBox(height: 3),
              Text(
                doctor.speciality.validate(value: 'General Practice'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: _slate),
              ),
              const Spacer(),
              Row(children: [
                const Icon(Icons.star_rounded,
                    size: 12, color: Color(0xFFF59E0B)),
                const SizedBox(width: 3),
                const Text('5.0',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _ink)),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: online ? _obsidian : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Book',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: online ? _white : _slate)),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Symptom chip ─────────────────────────────────────────────────────────────
class _SymptomChip extends StatelessWidget {
  final _Symptom symptom;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  const _SymptomChip(
      {required this.symptom,
      required this.isPressed,
      required this.onTapDown,
      required this.onTapUp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: () => onTapDown(),
      child: AnimatedScale(
        scale: isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isPressed ? kPrimary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPressed ? kPrimary.withOpacity(0.4) : _border,
              width: isPressed ? 1.5 : 1,
            ),
            boxShadow: isPressed
                ? []
                : [
                    const BoxShadow(
                      color: Color(0x07000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(symptom.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 7),
            Text(symptom.label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isPressed ? kPrimary : _ink)),
          ]),
        ),
      ),
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatDef stat;
  final Animation<double>? counterAnim;
  final int totalOnline;
  const _StatCard({required this.stat, this.counterAnim, this.totalOnline = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 22,
          height: 3,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: stat.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Animated counter for online count
        counterAnim != null
            ? AnimatedBuilder(
                animation: counterAnim!,
                builder: (_, __) {
                  final count = (counterAnim!.value * totalOnline).round();
                  return Text('$count',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: stat.color,
                          letterSpacing: -0.3));
                },
              )
            : Text(stat.value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: stat.color,
                    letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(stat.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 9,
                color: _slate,
                fontWeight: FontWeight.w500,
                height: 1.3)),
      ]),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _EmptyState(
      {required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Icon(icon, color: _slate.withOpacity(0.4), size: 32),
        const SizedBox(height: 10),
        Text(label,
            style: const TextStyle(
                color: _ink, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 3),
        Text(sub,
            style: TextStyle(color: _slate.withOpacity(0.7), fontSize: 12)),
      ]),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────
class _StatDef {
  final String value, label;
  final Color color;
  const _StatDef(this.value, this.label, this.color);
}

class _SvcDef {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback tap;
  const _SvcDef(this.label, this.icon, this.color, this.bg, this.tap);
}

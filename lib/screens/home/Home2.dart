import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import 'widgets/HomeHero.dart';
import 'widgets/SpecialtyRail.dart';
import 'widgets/ServiceGrid.dart';

class Home2 extends StatefulWidget {
  const Home2({super.key});
  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> with TickerProviderStateMixin {
  // ── Animation Controllers ──
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  late final AnimationController _orbCtrl;
  late final Animation<double> _orbAnim;

  late final AnimationController _shimCtrl;
  late final Animation<double> _shimAnim;

  late final AnimationController _heroCtrl;
  late final Animation<double> _heroSlide;
  late final Animation<double> _heroFade;

  late final AnimationController _docCtrl;
  late final Animation<double> _docAnim;

  // ── State ──
  List<UserModel> doctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchDoctors();
  }

  void _initAnimations() {
    // Pulse
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Orbs
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);

    // Shimmer
    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
    _shimAnim = Tween<double>(begin: -2.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimCtrl, curve: Curves.linear));

    // Hero Entry
    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _heroSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _heroFade = CurvedAnimation(
        parent: _heroCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut));

    // Lists Entry
    _docCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _docAnim = CurvedAnimation(parent: _docCtrl, curve: Curves.easeOutCubic);

    // Sequence
    _heroCtrl.forward();
  }

  Future<void> _fetchDoctors() async {
    try {
      doctors = await Get.find<DoctorService>().getAllDocs();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _docCtrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _orbCtrl.dispose();
    _shimCtrl.dispose();
    _heroCtrl.dispose();
    _docCtrl.dispose();

    super.dispose();
  }

  int get _onlineCount => doctors.where((d) => d.isAvailable.validate()).length;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: pageGray,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero Section ──
            SliverToBoxAdapter(
              child: HomeHero(
                heroSlide: _heroSlide,
                heroFade: _heroFade,
                pulseAnim: _pulseAnim,
                orbAnim: _orbAnim,
                onlineCount: _onlineCount,
                isLoading: _loading,
              ),
            ),

            // ── Services ──
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Medical Services'),
            ),
            const SliverToBoxAdapter(
              child: ServiceGrid(),
            ),

            // ── Departments ──
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Medical Departments',
                subtitle: 'Consult with a specialist instantly',
              ),
            ),
            SliverToBoxAdapter(
              child: SpecialtyRail(
                docAnim: _docAnim,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: boldTextStyle(size: 18, color: ink, letterSpacing: -0.5),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: secondaryTextStyle(size: 12, color: slate),
            ),
          ],
        ],
      ),
    );
  }
}

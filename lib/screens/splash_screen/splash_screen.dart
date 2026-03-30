import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:instant_doctor/controllers/ZegocloudController.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/onboarding/onboarding.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant/color.dart';
import '../../main.dart';
import '../../services/GetUserId.dart';

// ─── Warm Medical Palette ──────────────────────────────────────────────────────
const _bgTop = Color(0xFFEFF6FF); // very soft sky blue
const _bgMid = Color(0xFFF0FDF9); // barely-there mint
const _bgBot = Color(0xFFFFFFFF); // pure white
const _cardBg = Colors.white;
const _ink = Color(0xFF0F2744); // deep navy text
const _slate = Color(0xFF5E7A99); // soft secondary
const _green = Color(0xFF10B981); // healthy emerald
const _greenSoft = Color(0xFFD1FAE5); // pill background
const _red = Color(0xFFFF5A5A); // heartbeat red
const _white = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _zego = Get.find<ZegoCloudController>();
  final _auth = Get.find<AuthenticationController>();

  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl; // logo fade+scale in
  late final AnimationController _pulseCtrl; // outer ring breathe
  late final AnimationController _heartCtrl; // heartbeat line draw
  late final AnimationController _floatCtrl; // floating cross drift
  late final AnimationController _textCtrl; // text stagger
  late final AnimationController _dotCtrl; // loading dots
  late final AnimationController _crossCtrl; // rotating cross accent

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;
  late final Animation<double> _heartProgress;
  late final Animation<double> _floatY;
  late final Animation<double> _floatOpacity;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subFade;
  late final Animation<double> _pillFade;
  late final Animation<double> _crossRotate;

  // Dot loading state
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ── Logo gentle scale in ───────────────────────────────────────────────
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    // ── Gentle breathe ring ────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // ── Heartbeat line draw ────────────────────────────────────────────────
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _heartProgress = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));

    // ── Floating cross particles ───────────────────────────────────────────
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _floatY = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _floatOpacity = Tween<double>(begin: 0.06, end: 0.14)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Text stagger ───────────────────────────────────────────────────────
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _subFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.28, 0.72, curve: Curves.easeOut)));
    _pillFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut)));

    // ── Rotating + sign accent ─────────────────────────────────────────────
    _crossCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat();
    _crossRotate = Tween<double>(begin: 0, end: math.pi * 2)
        .animate(CurvedAnimation(parent: _crossCtrl, curve: Curves.linear));

    // ── Animated loading dots ──────────────────────────────────────────────
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _dotCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _activeDot = (_activeDot + 1) % 3);
        _dotCtrl.reset();
        _dotCtrl.forward();
      }
    });

    // ── Entry sequence ─────────────────────────────────────────────────────
    _logoCtrl.forward().then((_) {
      _textCtrl.forward();
      _dotCtrl.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _handleNext());
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _heartCtrl.dispose();
    _floatCtrl.dispose();
    _textCtrl.dispose();
    _dotCtrl.dispose();
    _crossCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ────────────────────────────────────────────────────────────
  Future<bool> _checkOTP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isOTPStage') ?? false;
  }

  Future<void> _handleNext() async {
    try {
      final results = await Future.wait<Object>([
        _checkOTP(),
        Get.putAsync(() async {
          final c = Get.put(ConnectivityController());
          await c.initConnectivity();
          return c;
        }),
      ]);
      final prefs = await SharedPreferences.getInstance();
      final isOTP = results[0] as bool;
      final userId = prefs.getString('userId').validate();

      if (isOTP) {
        // OTP screen
      } else if (user != null && userId.isNotEmpty) {
        await Future.wait<void>([getUserId(), _zego.handleInit()]);
        if (userController.pin.value.validate().isEmpty) {
          CreatePinScreen().launch(context, isNewTask: true);
        } else {
          AuthScreen(fromApp: false).launch(context, isNewTask: true);
        }
      } else {
        OnboardingScreen().launch(context);
      }
    } catch (e) {
      debugPrint('Splash: $e');
      OnboardingScreen().launch(context);
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(children: [
        // ── Soft warm gradient background ────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_bgTop, _bgMid, _bgBot],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── Floating medical cross particles ─────────────────────────────
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final v = _floatY.value;
            final opa = _floatOpacity.value;
            return Stack(children: [
              _FloatCross(
                  x: sw * 0.08,
                  y: sh * 0.12 - v * 18,
                  size: 22,
                  opacity: opa,
                  color: kPrimary),
              _FloatCross(
                  x: sw * 0.82,
                  y: sh * 0.18 + v * 12,
                  size: 16,
                  opacity: opa * 0.7,
                  color: _green),
              _FloatCross(
                  x: sw * 0.72,
                  y: sh * 0.72 - v * 20,
                  size: 20,
                  opacity: opa,
                  color: kPrimary),
              _FloatCross(
                  x: sw * 0.12,
                  y: sh * 0.78 + v * 14,
                  size: 14,
                  opacity: opa * 0.6,
                  color: _green),
              _FloatCross(
                  x: sw * 0.88,
                  y: sh * 0.55 - v * 10,
                  size: 12,
                  opacity: opa * 0.5,
                  color: kPrimary),
              _FloatCross(
                  x: sw * 0.45,
                  y: sh * 0.85 + v * 8,
                  size: 18,
                  opacity: opa * 0.55,
                  color: _green),
            ]);
          },
        ),

        // ── Main centred content ─────────────────────────────────────────
        SafeArea(
          child: Column(children: [
            // Upper 62% — logo + text
            Expanded(
              flex: 62,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // ── Logo cluster ───────────────────────────────────
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(alignment: Alignment.center, children: [
                      // Breathing outer ring
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: _pulseScale.value,
                          child: Container(
                            width: 152,
                            height: 152,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimary.withOpacity(_pulseOpacity.value),
                            ),
                          ),
                        ),
                      ),

                      // Soft shadow ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _white,
                          boxShadow: [
                            BoxShadow(
                                color: kPrimary.withOpacity(0.14),
                                blurRadius: 32,
                                spreadRadius: 4),
                            BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6)),
                          ],
                        ),
                      ),

                      // Rotating + accent (top-right corner of circle)
                      AnimatedBuilder(
                        animation: _crossRotate,
                        builder: (_, __) => Transform.rotate(
                          angle: _crossRotate.value,
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(children: [
                              Positioned(
                                top: 8,
                                right: 8,
                                child: _MedicalPlus(
                                    size: 18,
                                    color: kPrimary.withOpacity(0.3),
                                    thickness: 3),
                              ),
                            ]),
                          ),
                        ),
                      ),

                      // Logo image
                      AnimatedBuilder(
                        animation: _logoCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoFade.value.clamp(0.0, 1.0),
                            child: Container(
                              width: 116,
                              height: 116,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: _white),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/logo1.png",
                                  width: 62,
                                  height: 62,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 36),

                  // ── App name ─────────────────────────────────────────
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: Text(
                        'Instant Doctor',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.8,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Subtitle ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _subFade,
                    child: Text(
                      'Trusted healthcare, anytime',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: _slate,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── "Doctors online" green pill ───────────────────────
                  FadeTransition(
                    opacity: _pillFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _greenSoft,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        // Pulsing green dot
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _green,
                              boxShadow: [
                                BoxShadow(
                                  color: _green
                                      .withOpacity(_pulseOpacity.value * 3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Doctors available now',
                          style: TextStyle(
                            fontSize: 12,
                            color: _green.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),

            // Lower 38% — heartbeat + dots + tagline
            Expanded(
              flex: 38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ── Heartbeat / ECG line ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      height: 48,
                      child: AnimatedBuilder(
                        animation: _heartProgress,
                        builder: (_, __) => CustomPaint(
                          painter: _HeartbeatPainter(
                            progress: _heartProgress.value,
                            color: kPrimary,
                          ),
                          size: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Three bouncing loading dots ───────────────────────
                  FadeTransition(
                    opacity: _pillFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _activeDot == i ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _activeDot == i
                                ? kPrimary
                                : kPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Caption ───────────────────────────────────────────
                  FadeTransition(
                    opacity: _pillFade,
                    child: Text(
                      'Setting up your experience...',
                      style: TextStyle(
                        fontSize: 12,
                        color: _slate.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// =============================================================================
// FLOATING CROSS
// =============================================================================
class _FloatCross extends StatelessWidget {
  final double x, y, size, opacity;
  final Color color;
  const _FloatCross(
      {required this.x,
      required this.y,
      required this.size,
      required this.opacity,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: _MedicalPlus(size: size, color: color, thickness: size * 0.22),
      ),
    );
  }
}

// =============================================================================
// MEDICAL PLUS (+) WIDGET
// =============================================================================
class _MedicalPlus extends StatelessWidget {
  final double size, thickness;
  final Color color;
  const _MedicalPlus(
      {required this.size, required this.thickness, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        // Horizontal bar
        Container(
          width: size,
          height: thickness,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(thickness / 2),
          ),
        ),
        // Vertical bar
        Container(
          width: thickness,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(thickness / 2),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
// HEARTBEAT / ECG PAINTER
// =============================================================================
class _HeartbeatPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0, loops
  final Color color;
  const _HeartbeatPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    // ── ECG path normalised in x=[0..1], y=[-1..1] ──────────────────────
    // flat → flat → spike up → spike down → spike up (QRS) → flat → flat
    final points = <Offset>[
      const Offset(0.00, 0.0),
      const Offset(0.20, 0.0),
      const Offset(0.28, 0.0),
      const Offset(0.32, -0.18), // P wave
      const Offset(0.36, 0.0),
      const Offset(0.42, 0.0),
      const Offset(0.45, 0.12), // Q dip
      const Offset(0.50, -1.0), // R peak
      const Offset(0.54, 0.35), // S dip
      const Offset(0.58, 0.0),
      const Offset(0.65, -0.15), // T wave
      const Offset(0.72, 0.0),
      const Offset(1.00, 0.0),
    ];

    // ── Clip to progress so line "draws" left to right ───────────────────
    final clipX = w * progress;

    // Glow trail — wider, soft
    final glowPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Main line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final glowPath = Path();
    bool started = false;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = Offset(points[i].dx * w, cy + points[i].dy * cy * 0.9);
      final p1 = Offset(points[i + 1].dx * w, cy + points[i + 1].dy * cy * 0.9);

      if (p0.dx > clipX) break;

      if (!started) {
        path.moveTo(p0.dx, p0.dy);
        glowPath.moveTo(p0.dx, p0.dy);
        started = true;
      }

      // Clamp endpoint to progress
      final endX = p1.dx.clamp(0, clipX);
      final t = (p1.dx - p0.dx) == 0 ? 1.0 : (endX - p0.dx) / (p1.dx - p0.dx);
      final endY = p0.dy + (p1.dy - p0.dy) * t;

      path.lineTo(endX.toDouble(), endY);
      glowPath.lineTo(endX.toDouble(), endY);
    }

    canvas.drawPath(glowPath, glowPaint);
    canvas.drawPath(path, linePaint);

    // ── Moving dot at tip ─────────────────────────────────────────────────
    if (progress > 0.01 && progress < 0.99) {
      // Find current y at clipX by interpolating between last two points
      double dotY = cy;
      for (int i = 0; i < points.length - 1; i++) {
        final x0 = points[i].dx * w;
        final x1 = points[i + 1].dx * w;
        if (clipX >= x0 && clipX <= x1) {
          final t = (x1 - x0) == 0 ? 0.0 : (clipX - x0) / (x1 - x0);
          final y0 = cy + points[i].dy * cy * 0.9;
          final y1 = cy + points[i + 1].dy * cy * 0.9;
          dotY = y0 + (y1 - y0) * t;
          break;
        }
      }

      // Glow halo
      canvas.drawCircle(
        Offset(clipX, dotY),
        7,
        Paint()..color = color.withOpacity(0.15),
      );
      // Dot
      canvas.drawCircle(
        Offset(clipX, dotY),
        3.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter old) =>
      old.progress != progress;
}

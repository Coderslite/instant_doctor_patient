import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/ConnectivityController.dart';
import 'package:instant_doctor/controllers/ZegocloudController.dart';
import 'package:instant_doctor/screens/authentication/auth_screen.dart';
import 'package:instant_doctor/screens/authentication/create_pin.dart';
import 'package:instant_doctor/screens/onboarding/onboarding.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant/color.dart';
import '../../main.dart';
import '../../services/GetUserId.dart';

// ── Premium Medical Palette ──────────────────────────────────────────────────
const _bg = kPrimary;             // Brand Primary Blue solid background
const _ink = Colors.white;        // White for high contrast text
const _slate = Color(0xFFC7EFFE); // Soft sky-blue for subtext
const _green = Color(0xFF00FFCC); // Vibrant neon green/mint for "online" dot

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _zego = Get.find<ZegoCloudController>();

  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _heartCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _dotCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;
  late final Animation<double> _heartProgress;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subFade;

  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)));

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween<double>(begin: 0.2, end: 0.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _heartCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _heartProgress = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.linear));

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _subFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _dotCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _activeDot = (_activeDot + 1) % 3);
          _dotCtrl.reset();
          _dotCtrl.forward();
        }
      }
    });

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
    _textCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

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

      // Artificial delay for premium feel
      await Future.delayed(const Duration(milliseconds: 3500));

      if (isOTP) {
        // OTP logic
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
      OnboardingScreen().launch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bg,
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Logo Cluster
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing Rings
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Transform.scale(
                            scale: _pulseScale.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kPrimary.withOpacity(_pulseOpacity.value),
                              ),
                            ),
                          ),
                        ),
                        
                        // Premium Logo Container
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/logo1.png",
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // App Name
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: const Text(
                        'Instant Doctor',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  FadeTransition(
                    opacity: _subFade,
                    child: const Text(
                      'Trusted Healthcare, Anytime',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _slate,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Available Pill
                  FadeTransition(
                    opacity: _subFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _green,
                              boxShadow: [
                                BoxShadow(
                                  color: _green,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Doctors are online',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Heartbeat ECG
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: SizedBox(
                      height: 50,
                      child: AnimatedBuilder(
                        animation: _heartProgress,
                        builder: (_, __) => CustomPaint(
                          painter: _HeartbeatPainter(
                            progress: _heartProgress.value,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          size: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _activeDot == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _activeDot == i ? Colors.white : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _HeartbeatPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;
    
    final points = [
      const Offset(0.0, 0.0),
      const Offset(0.2, 0.0),
      const Offset(0.25, -0.3),
      const Offset(0.3, 0.0),
      const Offset(0.4, 0.0),
      const Offset(0.45, 1.0),
      const Offset(0.5, -1.0),
      const Offset(0.55, 0.3),
      const Offset(0.6, 0.0),
      const Offset(0.8, 0.0),
      const Offset(1.0, 0.0),
    ];

    final path = Path();
    path.moveTo(0, cy);
    
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = Offset(points[i].dx * w, cy + points[i].dy * (h / 2) * 0.9);
      final p1 = Offset(points[i+1].dx * w, cy + points[i+1].dy * (h / 2) * 0.9);
      
      final currentX = w * progress;
      if (p1.dx <= progress) {
        path.lineTo(p1.dx * w, cy + points[i+1].dy * (h / 2) * 0.9);
      } else if (p0.dx < progress) {
        final t = (progress - p0.dx) / (p1.dx - p0.dx);
        final y = p0.dy + (p1.dy - p0.dy) * t;
        path.lineTo(currentX, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter old) => old.progress != progress;
}

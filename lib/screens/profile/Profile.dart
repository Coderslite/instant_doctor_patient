import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/profile/about/About.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/screens/profile/personal/PersonalProfile.dart';
import 'package:instant_doctor/screens/profile/policy/Policy.dart';
import 'package:instant_doctor/screens/refer/ApplyRefer.dart';
import 'package:instant_doctor/screens/refer/Refer.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/ProfileImage.dart';
import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../controllers/ReferController.dart';
import '../../models/UserModel.dart';
import '../../services/GetAppVersion.dart';
import '../settings/SettingScreen.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
const _obsidian = Color(0xFF0A1628);
const _charcoal = Color(0xFF142035);
const _pageGray = Color(0xFFF0F4FA);
const _white = Colors.white;
const _ink = Color(0xFF0F2744);
const _slate = Color(0xFF5E7A99);
const _border = Color(0xFFE5EAF4);
const _gold = Color(0xFFE8B86D);
const _green = Color(0xFF10B981);
const _greenSoft = Color(0xFFD1FAE5);
const _redSoft = Color(0xFFFFEDED);
const _redText = Color(0xFFDC2626);
const _amberSoft = Color(0xFFFEF3C7);
const _amber = Color(0xFFF59E0B);

// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _auth = Get.put(AuthenticationController());
  final _referral = Get.put(ReferralController());

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _pulseOpacity = Tween<double>(begin: 0.20, end: 0.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
    _loadVersion();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    settingsController.version.value = await getAppVersion();
    if (mounted) setState(() {});
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageGray,
      body: Obx(() => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Obsidian hero sliver ─────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHero(context)),

              // ── Content ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _entrySlide,
                  child: FadeTransition(
                    opacity: _entryFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Column(children: [
                        internetCheck(),
                        countryCheck(),

                        const SizedBox(height: 20),
                        _buildStatsCard(),
                        const SizedBox(height: 24),
                        _buildSectionLabel('Account'),
                        const SizedBox(height: 10),
                        _buildMenuGroup([
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Personal Information',
                            sub: 'Update your personal details',
                            color: kPrimary,
                            onTap: () => const PersonalProfileScreen(
                              isModal: false,
                            ).launch(context),
                          ),
                          _MenuItem(
                            icon: Icons.favorite_border_rounded,
                            label: 'Medical Data',
                            sub: 'Manage your health records',
                            color: _redText,
                            colorBg: _redSoft,
                            onTap: () => const MedicalDataScreen(
                              isModal: false,
                            ).launch(context),
                          ),
                          if (userController.referralEnabled.value)
                            _MenuItem(
                              icon: Icons.card_giftcard_rounded,
                              label: 'Referral',
                              sub: 'Refer friends and earn rewards',
                              color: _amber,
                              colorBg: _amberSoft,
                              onTap: () =>
                                  userController.referralProgramApplied.value
                                      ? ReferScreen().launch(context)
                                      : ApplyReferralProgramScreen()
                                          .launch(context),
                            ),
                        ]),

                        const SizedBox(height: 20),
                        _buildSectionLabel('Legal & Support'),
                        const SizedBox(height: 10),
                        _buildMenuGroup([
                          _MenuItem(
                            icon: Icons.shield_outlined,
                            label: 'Privacy Policy',
                            sub: 'How we protect your data',
                            color: const Color(0xFF8B5CF6),
                            colorBg: const Color(0xFFF3EFFE),
                            onTap: () => launchUrl(Uri.parse(
                                'http://instantdoctor.co/privacy.php')),
                          ),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            label: 'Terms & Conditions',
                            sub: 'Read our full policy',
                            color: const Color(0xFF0EA5E9),
                            colorBg: const Color(0xFFE0F2FE),
                            onTap: () => const PolicyScreen().launch(context),
                          ),
                          _MenuItem(
                            icon: Icons.headset_mic_outlined,
                            label: 'Help & Support',
                            sub: 'Get in touch with our team',
                            color: _green,
                            colorBg: _greenSoft,
                            onTap: () => const HelpScreen().launch(context),
                          ),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            label: 'About Instant Doctor',
                            sub: 'App info & version',
                            color: _slate,
                            colorBg: const Color(0xFFF1F5F9),
                            onTap: () => AboutScreen(
                                    version: settingsController.version.value)
                                .launch(context),
                          ),
                        ]),

                        const SizedBox(height: 28),

                        // Version
                        Text(
                          'Version ${settingsController.version.value}',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: _slate.withOpacity(0.55),
                              letterSpacing: 0.3),
                        ),

                        const SizedBox(height: 16),

                        // Sign out
                        _SignOutButton(
                          onTap: () => _auth.handleLogout(context),
                        ),

                        const SizedBox(height: 160),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: userService.getProfile(userId: userController.userId.value),
      builder: (_, snap) {
        final user = snap.data;
        return Container(
          color: _obsidian,
          child: Stack(children: [
            // Top-right orb
            Positioned(
              right: -50,
              top: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                      colors: [kPrimary.withOpacity(0.12), Colors.transparent]),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
                  child: Row(children: [
                    const Expanded(
                      child: Text('My Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _white,
                            letterSpacing: -0.4,
                          )),
                    ),
                    // Settings button
                    GestureDetector(
                      onTap: () => const SettingScreen().launch(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: _white.withOpacity(0.12), width: 1),
                        ),
                        child: Icon(Icons.settings_outlined,
                            color: _white.withOpacity(0.8), size: 18),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 24),

                // Avatar + name
                Stack(alignment: Alignment.center, children: [
                  // Breathing glow
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimary.withOpacity(_pulseOpacity.value),
                        ),
                      ),
                    ),
                  ),
                  // Gold ring
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: _gold.withOpacity(0.65), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipOval(
                      child: profileImage(user ?? UserModel(), 92, 92,
                          context: context),
                    ),
                  ),
                  // Edit badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => const PersonalProfileScreen(
                        isModal: false,
                      ).launch(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: _obsidian, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.4),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 13, color: _white),
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 14),

                if (user != null) ...[
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email.validate(),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ] else
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kPrimary),
                  ),

                const SizedBox(height: 28),

                // Bridge curve into page gray
                Container(
                  height: 28,
                  decoration: const BoxDecoration(
                    color: _pageGray,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }

  // ── Stats card ──────────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return StreamBuilder<UserModel>(
      stream: userService.getProfile(userId: userController.userId.value),
      builder: (_, snap) {
        if (!snap.hasData) {
          return _shimmerCard();
        }
        final user = snap.data!;
        final personalOk =
            user.dob != null && user.address.validate().isNotEmpty;
        final medicalOk = user.bloodGroup.validate().isNotEmpty &&
            user.weight.validate().isNotEmpty &&
            user.height.validate().isNotEmpty;

        if (!personalOk) {
          return _IncompleteCard(
              isMedical: false,
              onTap: () async {
                await const PersonalProfileScreen(
                  isModal: false,
                ).launch(context);
                setState(() {});
              });
        }
        if (!medicalOk) {
          return _IncompleteCard(
              isMedical: true,
              onTap: () async {
                await const MedicalDataScreen(
                  isModal: false,
                ).launch(context);
                setState(() {});
              });
        }

        // Complete stats
        final age =
            ((DateTime.now().difference(user.dob!.toDate())).inDays ~/ 365);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kPrimaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                  color: kPrimary.withOpacity(0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.monitor_heart_outlined, color: _white, size: 16),
              const SizedBox(width: 7),
              Text('Health Summary',
                  style: TextStyle(
                    fontSize: 12,
                    color: _white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  )),
            ]),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatPill('Age', '$age yrs', Icons.cake_outlined),
                _StatPill(
                    'Blood',
                    user.bloodGroup.validate().isNotEmpty
                        ? user.bloodGroup!
                        : 'N/A',
                    Icons.water_drop_outlined),
                _StatPill('Weight', '${user.weight.validate()} kg',
                    Icons.monitor_weight_outlined),
                _StatPill('Height', '${user.height.validate()} cm',
                    Icons.height_rounded),
              ],
            ),
          ]),
        );
      },
    );
  }

  Widget _shimmerCard() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF5),
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _slate.withOpacity(0.7),
            letterSpacing: 1.2,
          )),
    );
  }

  Widget _buildMenuGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _MenuTile(item: item, isLast: isLast);
        }),
      ),
    );
  }
}

// =============================================================================
// STAT PILL
// =============================================================================
class _StatPill extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatPill(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: _white, size: 18),
      ),
      const SizedBox(height: 7),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _white,
              letterSpacing: -0.2)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              fontSize: 10,
              color: _white.withOpacity(0.55),
              fontWeight: FontWeight.w400)),
    ]);
  }
}

// =============================================================================
// INCOMPLETE PROFILE CARD
// =============================================================================
class _IncompleteCard extends StatelessWidget {
  final bool isMedical;
  final VoidCallback onTap;
  const _IncompleteCard({required this.isMedical, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: _amber.withOpacity(0.30),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child:
              const Icon(Icons.warning_amber_rounded, color: _white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile Incomplete',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _white,
                    letterSpacing: -0.2)),
            const SizedBox(height: 3),
            Text(
              isMedical
                  ? 'Add medical data to unlock all features'
                  : 'Complete your profile to get started',
              style: TextStyle(
                  fontSize: 11.5, color: _white.withOpacity(0.75), height: 1.4),
            ),
          ],
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Fix Now',
                style: TextStyle(
                  fontSize: 11.5,
                  color: _amber,
                  fontWeight: FontWeight.w800,
                )),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
// MENU TILE
// =============================================================================
class _MenuItem {
  final IconData icon;
  final String label, sub;
  final Color color;
  final Color? colorBg;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
    this.colorBg,
  });
}

class _MenuTile extends StatefulWidget {
  final _MenuItem item;
  final bool isLast;
  const _MenuTile({required this.item, required this.isLast});
  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  final bool _pressed = false;

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
    final bg = widget.item.colorBg ?? widget.item.color.withOpacity(0.08);

    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.item.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              // Icon box
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(widget.item.icon, color: widget.item.color, size: 20),
              ),
              const SizedBox(width: 14),
              // Labels
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                        letterSpacing: -0.1,
                      )),
                  const SizedBox(height: 2),
                  Text(widget.item.sub,
                      style: TextStyle(
                          fontSize: 11.5, color: _slate.withOpacity(0.8))),
                ],
              )),
              Icon(Icons.chevron_right_rounded,
                  color: _slate.withOpacity(0.4), size: 18),
            ]),
          ),
          if (!widget.isLast)
            Padding(
              padding: const EdgeInsets.only(left: 72),
              child: Divider(height: 1, color: _border),
            ),
        ]),
      ),
    );
  }
}

// =============================================================================
// SIGN OUT BUTTON
// =============================================================================
class _SignOutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});
  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton>
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
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _redSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _redText.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.logout_rounded, size: 18, color: _redText),
              SizedBox(width: 10),
              Text('Sign Out',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _redText,
                    letterSpacing: 0.1,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

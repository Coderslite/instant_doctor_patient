// ignore_for_file: file_names
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/UserController.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/ProfileImage.dart';
import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../controllers/BookingController.dart';
import '../../controllers/SettingController.dart';
import '../../controllers/showPayment.dart';
import '../../services/AppointmentService.dart';
import '../../services/UserService.dart';
import '../chat/ChatInterface.dart';

// ─── Palette ───────────────────────────────────────────────────────────────────
const _obsidian = Color(0xFF0A1628);
const _charcoal = Color(0xFF142035);
const _pageGray = Color(0xFFF0F4FA);
const _white = Colors.white;
const _ink = Color(0xFF0F2744);
const _slate = Color(0xFF5E7A99);
const _border = Color(0xFFE5EAF4);
const _green = Color(0xFF10B981);
const _greenSoft = Color(0xFFD1FAE5);
const _amber = Color(0xFFF59E0B);
const _amberSoft = Color(0xFFFEF3C7);
const _redSoft = Color(0xFFFFEDED);
const _redText = Color(0xFFDC2626);

// ─────────────────────────────────────────────────────────────────────────────
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});
  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with TickerProviderStateMixin {
  final SettingsController settingsController = Get.find();
  final AppointmentService appointmentService = AppointmentService();
  final UserController userController = Get.put(UserController());
  final UserService userService = Get.find();

  // Shimmer animation
  late final AnimationController _shimCtrl;
  late final Animation<double> _shimAnim;

  // FAB pulse
  late final AnimationController _fabCtrl;
  late final Animation<double> _fabPulse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _shimCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300))
      ..repeat();
    _shimAnim = Tween<double>(begin: -2.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimCtrl, curve: Curves.linear));

    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _fabPulse = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fabCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shimCtrl.dispose();
    _fabCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageGray,
      body: Column(children: [
        // ── Premium header ─────────────────────────────────────────────────
        _AppointmentHeader(userController: userController),

        internetCheck(),
        countryCheck(),

        // ── Content ────────────────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<AppointmentModel>>(
            stream: userController.userId.isEmpty
                ? null
                : appointmentService
                    .getAllAppointment(userController.userId.value),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ErrorState(onRetry: () => setState(() {}));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _ShimmerList(shimAnim: _shimAnim);
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return _EmptyState(
                    onBook: () => NewAppointment().launch(context));
              }
              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (_, i) {
                    final appt = data[i];
                    final now = Timestamp.now();
                    final isExp = now.compareTo(appt.endTime!) > 0;
                    final isOng = now.compareTo(appt.startTime!) >= 0 &&
                        now.compareTo(appt.endTime!) <= 0;
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 420),
                      child: SlideAnimation(
                        verticalOffset: 36,
                        child: FadeInAnimation(
                          child: _AppointmentCard(
                            appointment: appt,
                            isExpired: isExp,
                            isOngoing: isOng,
                            onTap: () => _handleTap(appt, isExp),
                            onDelete: () => _confirmDelete(appt),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ]),

      // ── Glowing FAB ──────────────────────────────────────────────────────
      floatingActionButton: AnimatedBuilder(
        animation: _fabPulse,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Glow halo
            Container(
              width: 64 + _fabPulse.value * 12,
              height: 64 + _fabPulse.value * 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.18 * (1 - _fabPulse.value)),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                NewAppointment().launch(context);
              },
              backgroundColor: kPrimary,
              elevation: 0,
              child: const Icon(Icons.add_rounded, color: _white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Logic (unchanged) ──────────────────────────────────────────────────────
  Future<void> _handleTap(AppointmentModel appt, bool isExpired) async {
    HapticFeedback.selectionClick();
    if (isExpired && appt.isPaid == false) {
      errorSnackBar(context: context, title: 'This appointment has expired');
      return;
    }
    if (!appt.isPaid.validate() && !appt.isTrial.validate()) {
      await _showPaymentDialog(appt);
      return;
    }
    if (appt.doctorId.validate().isEmpty) {
      errorSnackBar(
          context: context, title: 'Appointment not yet assigned to a doctor');
      return;
    }
    ChatInterface(
      appointmentId: appt.id!,
      docId: appt.doctorId!,
      appointment: appt,
      videocallToken: appt.videocallToken.validate(),
      isExpired: isExpired,
      update: () => setState(() {}),
    ).launch(context);
  }

  Future<void> _confirmDelete(AppointmentModel appt) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(),
    );
    if (ok == true) {
      await appointmentService.deleteAppointment(
          appointmentId: appt.id.validate());
      successSnackBar(context: context, title: 'Appointment deleted');
    }
  }

  Future<void> _showPaymentDialog(AppointmentModel appt) async {
    await showDialog(
      context: context,
      builder: (_) => _PaymentDialog(
        onPay: () {
          Navigator.pop(context);
          _handleMakePayment(appt);
        },
      ),
    );
  }

  void _handleMakePayment(AppointmentModel appt) {
    final bookingController = Get.find<BookingController>();
    try {
      bookingController.isLoading.value = true;
      handleShowPaymentOption(context, appointment: appt);
    } finally {
      bookingController.isLoading.value = false;
    }
  }
}

// =============================================================================
// HEADER
// =============================================================================
class _AppointmentHeader extends StatelessWidget {
  final UserController userController;
  const _AppointmentHeader({required this.userController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _obsidian,
        boxShadow: [
          BoxShadow(
              color: Color(0x28000000), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
          child: Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Appointments',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _white,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 4),
                Text('Tap any card to open your consultation',
                    style: TextStyle(
                      fontSize: 12,
                      color: _white.withOpacity(0.4),
                      fontWeight: FontWeight.w400,
                    )),
              ],
            )),
            // Calendar icon button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _white.withOpacity(0.12), width: 1),
              ),
              child: Icon(Icons.calendar_month_rounded,
                  color: _white.withOpacity(0.8), size: 20),
            ),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
// APPOINTMENT CARD
// =============================================================================
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isExpired;
  final bool isOngoing;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AppointmentCard({
    required this.appointment,
    required this.isExpired,
    required this.isOngoing,
    required this.onTap,
    required this.onDelete,
  });

  Color get _statusColor {
    if (isOngoing) return _green;
    if (isExpired) return _slate;
    return _amber;
  }

  Color get _statusBg {
    if (isOngoing) return _greenSoft;
    if (isExpired) return const Color(0xFFF1F5F9);
    return _amberSoft;
  }

  String get _statusLabel {
    if (isOngoing) return 'In Progress';
    if (isExpired) return 'Completed';
    return 'Upcoming';
  }

  IconData get _statusIcon {
    if (isOngoing) return Icons.circle_rounded;
    if (isExpired) return Icons.check_circle_outline_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = isExpired || !appointment.isPaid.validate();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        enabled: canDelete,
        key: ValueKey(appointment.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: onDelete),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: _redText,
              foregroundColor: _white,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              borderRadius: BorderRadius.circular(20),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border, width: 1),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x07000000),
                    blurRadius: 12,
                    offset: Offset(0, 4))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(children: [
                // ── Status strip ───────────────────────────────────────
                Container(
                  width: 4,
                  height: 100,
                  color: _statusColor,
                ),

                // ── Main content ───────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row — doctor info + status badge
                        appointment.isPaid.validate()
                            ? appointment.doctorId.validate().isEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Doctor Unassigned",
                                        style: boldTextStyle(),
                                      ),
                                      Text(
                                        "A doctor will be assigned to you shortly",
                                        style: secondaryTextStyle(size: 12),
                                      ),
                                    ],
                                  )
                                : StreamBuilder<UserModel>(
                                    stream: userService.getProfile(
                                        userId:
                                            appointment.doctorId.validate()),
                                    builder: (context, asyncSnapshot) {
                                      if (asyncSnapshot.hasData) {
                                        var doctor = asyncSnapshot.data!;
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Doctor avatar placeholder
                                            profileImage(doctor, 48, 48,
                                                context: context),
                                            const SizedBox(width: 12),

                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  appointment.doctorId
                                                          .validate()
                                                          .isNotEmpty
                                                      ? 'Dr. ${"${doctor.firstName.validate()} ${doctor.lastName.validate()}"}'
                                                      : 'Doctor Unassigned',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: _ink,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  _formatTime(
                                                      appointment.startTime),
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: _slate,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            )),

                                            // Status badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: _statusBg,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(_statusIcon,
                                                      size: 9,
                                                      color: _statusColor),
                                                  const SizedBox(width: 4),
                                                  Text(_statusLabel,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: _statusColor,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Container();
                                    })
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pending Payment",
                                    style: boldTextStyle(),
                                  ),
                                  Text(
                                    "please complete your payment for this appointment",
                                    style: secondaryTextStyle(size: 12),
                                  ),
                                ],
                              ),

                        const SizedBox(height: 12),
                        Container(height: 1, color: _border),
                        const SizedBox(height: 10),

                        // Bottom row — paid status + action chip
                        Row(children: [
                          // Payment indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: appointment.isPaid.validate()
                                  ? _greenSoft
                                  : _redSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  appointment.isPaid.validate()
                                      ? Icons.check_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 11,
                                  color: appointment.isPaid.validate()
                                      ? _green
                                      : _redText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.isPaid.validate()
                                      ? 'Paid'
                                      : 'Payment Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: appointment.isPaid.validate()
                                        ? _green
                                        : _redText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Action chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? const Color(0xFFF1F5F9)
                                  : kPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isExpired ? 'View' : 'Open Chat',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isExpired ? _slate : _white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpired
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.chat_bubble_outline_rounded,
                                  size: 10,
                                  color: isExpired ? _slate : _white,
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return 'Time not set';
    final dt = ts.toDate();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ·  $h12:$m $ap';
  }
}

// =============================================================================
// SHIMMER LOADING
// =============================================================================
class _ShimmerList extends StatelessWidget {
  final Animation<double> shimAnim;
  const _ShimmerList({required this.shimAnim});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 4,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnimatedBuilder(
          animation: shimAnim,
          builder: (_, __) => Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(shimAnim.value - 1, 0),
                end: Alignment(shimAnim.value + 1, 0),
                colors: const [
                  Color(0xFFE8EDF5),
                  Colors.white,
                  Color(0xFFE8EDF5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================
class _EmptyState extends StatelessWidget {
  final VoidCallback onBook;
  const _EmptyState({required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon cluster
            Stack(alignment: Alignment.center, children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.06),
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withOpacity(0.10),
                ),
              ),
              Icon(Icons.calendar_today_rounded,
                  size: 36, color: kPrimary.withOpacity(0.6)),
            ]),

            const SizedBox(height: 24),
            const Text('No Appointments Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.4,
                )),
            const SizedBox(height: 10),
            Text(
              'Book a consultation with a specialist\nand get care in under 5 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: _slate, height: 1.55),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onBook();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, color: _white, size: 18),
                    SizedBox(width: 8),
                    Text('Book Appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _white,
                          letterSpacing: 0.1,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _redSoft,
              ),
              child:
                  const Icon(Icons.wifi_off_rounded, color: _redText, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text(
                'We couldn\'t load your appointments.\nPlease check your connection.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _slate, height: 1.5)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _redSoft,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _redText.withOpacity(0.25), width: 1),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.refresh_rounded, color: _redText, size: 16),
                  SizedBox(width: 8),
                  Text('Try Again',
                      style: TextStyle(
                          fontSize: 13,
                          color: _redText,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DIALOGS
// =============================================================================
class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: _redSoft),
            child: const Icon(Icons.delete_outline_rounded,
                color: _redText, size: 26),
          ),
          const SizedBox(height: 16),
          const Text('Delete Appointment',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 8),
          Text(
              'This action cannot be undone. The appointment record will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _slate, height: 1.5)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _slate))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _redSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _redText.withOpacity(0.25)),
                  ),
                  child: const Center(
                      child: Text('Delete',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _redText))),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _PaymentDialog extends StatelessWidget {
  final VoidCallback onPay;
  const _PaymentDialog({required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary.withOpacity(0.08),
            ),
            child: Icon(Icons.lock_open_rounded, color: kPrimary, size: 26),
          ),
          const SizedBox(height: 16),
          const Text('Payment Required',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 8),
          Text(
              'Complete your payment to access this consultation and chat with your doctor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _slate, height: 1.5)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                      child: Text('Later',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _slate))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onPay,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kPrimaryDark]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                      child: Text('Pay Now',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _white))),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

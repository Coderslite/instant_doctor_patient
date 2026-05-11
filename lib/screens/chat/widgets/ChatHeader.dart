import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:instant_doctor/models/AppointmentModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/DoctorService.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/component/TimeRemaining.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/doctors/SingleDoctor.dart';
import 'package:instant_doctor/screens/prescription/Prescription.dart';
import 'package:instant_doctor/screens/profile/help/LiveChat.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final String docId;
  final AppointmentModel appointment;
  final DoctorService doctorService;
  final Animation<double> pulseAnim;
  final bool isExpired;
  final bool isYetToStart;
  final String userName;
  final String appointmentId;
  final UserModel? doctor;

  const ChatHeader({
    super.key,
    required this.docId,
    required this.appointment,
    required this.doctorService,
    required this.pulseAnim,
    required this.isExpired,
    required this.isYetToStart,
    required this.userName,
    required this.appointmentId,
    this.doctor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: obsidian,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 10),
          child: Row(children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: white),
            ),
            Expanded(
              child: StreamBuilder<UserModel>(
                stream: doctorService.getDoc(docId: docId),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final doc = snap.data!;
                  final online = doc.status.validate() == ONLINE;
                  return GestureDetector(
                    onTap: () {
                      if (doctor != null) {
                        SingleDoctorScreen(doctor: doctor!).launch(context);
                      }
                    },
                    child: Row(children: [
                      Stack(children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: online
                                  ? green.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profileImage(doc, 42, 42, context: context),
                          ),
                        ),
                        if (online)
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: AnimatedBuilder(
                              animation: pulseAnim,
                              builder: (_, __) => Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: green,
                                  border:
                                      Border.all(color: obsidian, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: green
                                          .withOpacity(pulseAnim.value * 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${doc.firstName} ${doc.lastName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(children: [
                            if (online)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: green.withOpacity(0.3), width: 1),
                                ),
                                child: const Text('Online',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: green,
                                        fontWeight: FontWeight.w600)),
                              )
                            else
                              Text(
                                doc.lastSeen == null
                                    ? 'Offline'
                                    : 'Last seen ${timeago.format(doc.lastSeen!.toDate())}',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.4)),
                              ),
                          ]),
                          if (appointment.isPaid.validate() || !isExpired) ...[
                            const SizedBox(width: 8),
                            TimeRemaining(appointment: appointment),
                          ],
                        ],
                      )),
                    ]),
                  );
                },
              ),
            ),
            _HeaderIconBtn(
              icon: Icons.call_outlined,
              onTap: () => _showCallSheet(context),
            ),
            const SizedBox(width: 4),
            PopupMenuButton(
              color: obsidian,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.more_vert_rounded, color: white, size: 22),
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () {
                    if (doctor != null) {
                      SingleDoctorScreen(doctor: doctor!).launch(context);
                    }
                  },
                  child: _popItem(Icons.person_outline_rounded, 'Doctor Info'),
                ),
                PopupMenuItem(
                  onTap: () => PrescriptionScreen(appointment: appointment)
                      .launch(context),
                  child: _popItem(Icons.description_outlined, 'Prescriptions'),
                ),
                PopupMenuItem(
                  onTap: () => LiveChatScreen().launch(context),
                  child: _popItem(Icons.flag_outlined, 'Report Appointment'),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _popItem(IconData icon, String label) => Row(children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
      ]);

  void _showCallSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CallSheet(
        appointmentId: appointmentId,
        appointment: appointment,
        userName: userName,
        isExpired: isExpired,
        isYetToStart: isYetToStart,
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _CallSheet extends StatelessWidget {
  final String appointmentId;
  final AppointmentModel appointment;
  final String userName;
  final bool isExpired;
  final bool isYetToStart;

  const _CallSheet({
    required this.appointmentId,
    required this.appointment,
    required this.userName,
    required this.isExpired,
    required this.isYetToStart,
  });

  void _guard(BuildContext ctx) {
    if (isYetToStart) {
      toast('Appointment is yet to commence');
      return;
    }
    if (isExpired) {
      toast('Appointment has expired');
      return;
    }
    if (!appointment.isPaid.validate()) {
      toast("Payment not made for this appointment");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    const ink = Color(0xFF0F2744);
    const border = Color(0xFFE5EAF4);
    const green = Color(0xFF10B981);
    final canCall =
        !isExpired && appointment.isPaid.validate() && !isYetToStart;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Start a Call',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ink,
                letterSpacing: -0.3)),
        const SizedBox(height: 24),
        _CallOption(
          icon: Icons.videocam_rounded,
          label: 'Video Call',
          color: kPrimary,
          enabled: canCall,
          invitees: [
            ZegoUIKitUser(id: appointment.doctorId.validate(), name: 'Doctor')
          ],
          isVideo: true,
          appointmentId: appointmentId,
          onGuard: () => _guard(context),
        ),
        const SizedBox(height: 12),
        _CallOption(
          icon: Icons.call_rounded,
          label: 'Audio Call',
          color: green,
          enabled: canCall,
          invitees: [
            ZegoUIKitUser(id: appointment.doctorId.validate(), name: 'Doctor')
          ],
          isVideo: false,
          appointmentId: appointmentId,
          onGuard: () => _guard(context),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
      ]),
    );
  }
}

class _CallOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final List<ZegoUIKitUser> invitees;
  final bool isVideo;
  final String appointmentId;
  final VoidCallback onGuard;

  const _CallOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.invitees,
    required this.isVideo,
    required this.appointmentId,
    required this.onGuard,
  });

  @override
  Widget build(BuildContext context) {
    const slate = Color(0xFF5E7A99);
    const ink = Color(0xFF0F2744);
    const border = Color(0xFFE5EAF4);

    return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 70),
        child: Container(
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.07) : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: enabled ? color.withOpacity(0.2) : border, width: 1),
          ),
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: enabled ? color.withOpacity(0.12) : border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: enabled ? color : slate, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: enabled ? ink : slate)),
                        Text(
                            isVideo
                                ? 'Start a face-to-face consultation'
                                : 'High-quality voice only call',
                            style: TextStyle(
                                fontSize: 11, color: slate.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ]),
              ),
              if (enabled)
                Positioned.fill(
                  child: ZegoSendCallInvitationButton(
                    isVideoCall: isVideo,
                    resourceID: "instantdoctorservice",
                    invitees: invitees,
                    callID: appointmentId,
                    buttonSize: const Size(double.infinity, double.infinity),
                    iconVisible: false,
                    clickableBackgroundColor: Colors.transparent,
                  ),
                )
              else
                Positioned.fill(
                  child: GestureDetector(onTap: onGuard),
                ),
            ],
          ),
        ));
  }
}

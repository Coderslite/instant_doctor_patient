import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/component/ProfileImage.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorRail extends StatelessWidget {
  final List<UserModel> doctors;
  final bool isLoading;
  final Animation<double> docAnim;
  final Animation<double> pulseAnim;
  final Animation<double> shimAnim;

  const DoctorRail({
    super.key,
    required this.doctors,
    required this.isLoading,
    required this.docAnim,
    required this.pulseAnim,
    required this.shimAnim,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => _DoctorShimmer(shimAnim: shimAnim),
        ),
      );
    }

    if (doctors.isEmpty) {
      return const _EmptyDoctors();
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        physics: const BouncingScrollPhysics(),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final delay = i * 0.1;
          return AnimatedBuilder(
            animation: docAnim,
            builder: (_, __) {
              final progress = ((docAnim.value - delay) / (1 - delay)).clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset((1 - progress) * 30, 0),
                child: Opacity(
                  opacity: progress,
                  child: _DoctorCard(
                    doctor: doctors[i],
                    pulse: pulseAnim,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final UserModel doctor;
  final Animation<double> pulse;

  const _DoctorCard({required this.doctor, required this.pulse});

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final online = widget.doctor.isAvailable.validate();

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        NewAppointment(doctorId: widget.doctor.id).launch(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: online ? kPrimary.withOpacity(0.15) : border.withOpacity(0.5), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: obsidian.withOpacity(0.04), 
                blurRadius: 15, 
                offset: const Offset(0, 8)
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: pageGray, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: obsidian.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: profileImage(widget.doctor, 52, 52, context: context),
                    ),
                  ),
                  _StatusBadge(online: online, pulse: widget.pulse),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.doctor.firstName.validate()} ${widget.doctor.lastName.validate()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: boldTextStyle(size: 14, color: ink, letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),
              Text(
                widget.doctor.speciality.validate(value: 'Medical Doctor'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: secondaryTextStyle(size: 11, color: slate),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: amber),
                      const SizedBox(width: 4),
                      Text('4.9', style: boldTextStyle(size: 11, color: ink)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: online ? obsidian : pageGray,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: online ? [
                        BoxShadow(
                          color: obsidian.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Text(
                      'Book',
                      style: boldTextStyle(size: 10, color: online ? white : slate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool online;
  final Animation<double> pulse;

  const _StatusBadge({required this.online, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: online ? kPrimary.withOpacity(0.08) : pageGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: online ? kPrimary.withOpacity(0.1) : border.withOpacity(0.5),
            width: 1
          ),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: online ? pulse.value : 0.5,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: online ? kPrimary : slate,
                  boxShadow: online ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ] : null,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              online ? 'LIVE' : 'AWAY',
              style: boldTextStyle(size: 9, color: online ? kPrimary : slate, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorShimmer extends StatelessWidget {
  final Animation<double> shimAnim;
  const _DoctorShimmer({required this.shimAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimAnim,
      builder: (_, __) => Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment(shimAnim.value - 1, 0),
            end: Alignment(shimAnim.value + 1, 0),
            colors: const [Color(0xFFF1F5F9), white, Color(0xFFF1F5F9)],
          ),
        ),
      ),
    );
  }
}

class _EmptyDoctors extends StatelessWidget {
  const _EmptyDoctors();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(Icons.medical_services_outlined, color: slate.withOpacity(0.3), size: 32),
          const SizedBox(height: 12),
          Text('No doctors online', style: boldTextStyle(size: 14, color: ink)),
          Text('Please check back in a few minutes', style: secondaryTextStyle(size: 11)),
        ],
      ),
    );
  }
}

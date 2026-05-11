import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/appointment/AppointmentPricing.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';
import '../../models/UserModel.dart';
import '../../services/ReviewService.dart';

class SingleDoctorScreen extends StatefulWidget {
  final UserModel doctor;
  const SingleDoctorScreen({super.key, required this.doctor});

  @override
  State<SingleDoctorScreen> createState() => _SingleDoctorScreenState();
}

class _SingleDoctorScreenState extends State<SingleDoctorScreen> {
  final reviewService = Get.find<ReviewService>();
  int totalReview = 0;

  @override
  void initState() {
    super.initState();
    handleGetTotalReview();
  }

  handleGetTotalReview() async {
    totalReview = await reviewService.getDoctorReviewsCount(
        docId: widget.doctor.id.validate());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: _buildContent(),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      elevation: 0,
      backgroundColor: kPrimary,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: backButton(context).center(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.doctor.photoUrl.validate().isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.doctor.photoUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                : Image.asset(
                    "assets/images/avatar2.png",
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    kText.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: const BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Name and Speciality
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${widget.doctor.firstName} ${widget.doctor.lastName}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: kText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      4.height,
                      Text(
                        widget.doctor.speciality.validate(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: kSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: kGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded,
                      color: kGreen, size: 24),
                ),
              ],
            ),
            24.height,

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                    "Patients", "1.2K+", Icons.people_alt_rounded, kPrimary),
                _buildStatItem(
                    "Experience",
                    "${widget.doctor.experience.validate()} Yrs",
                    Icons.work_history_rounded,
                    Colors.orange),
                _buildStatItem(
                    "Rating", "4.8", Icons.star_rounded, Colors.amber),
              ],
            ),
            32.height,

            // About Section
            const Text(
              "About Doctor",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            12.height,
            Text(
              widget.doctor.bio.validate().isEmpty
                  ? "Dr. ${widget.doctor.lastName} is a highly experienced professional dedicated to providing the best medical care to patients."
                  : widget.doctor.bio.validate(),
              style: const TextStyle(
                fontSize: 15,
                color: kSub,
                height: 1.6,
              ),
            ),
            32.height,

            // Specializations
            const Text(
              "Specialization",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            16.height,
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildChip(widget.doctor.speciality.validate()),
              ],
            ),

            if (widget.doctor.otherLanguage.validate().isNotEmpty) ...[
              32.height,
              const Text(
                "Languages",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              16.height,
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.doctor.otherLanguage
                    .validate()
                    .split(',')
                    .map((lang) =>
                        _buildChip(lang.trim().capitalizeFirstLetter()))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kText.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          8.height,
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
          4.height,
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kSub,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: kText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

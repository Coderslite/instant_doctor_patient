import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../services/formatTime.dart';

class ActiveMedicationScreen extends StatefulWidget {
  final MedicationModel medication;
  const ActiveMedicationScreen({super.key, required this.medication});

  @override
  State<ActiveMedicationScreen> createState() => _ActiveMedicationScreenState();
}

class _ActiveMedicationScreenState extends State<ActiveMedicationScreen> {
  late MedicationModel _medication;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime currentDate;
  late DateTime startDate;
  late DateTime endDate;
  late int currentDay;
  late int totalDays;
  late double progressValue;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    _medication = widget.medication;
    _initializeTracking();
    _calculateDates();
  }

  void _initializeTracking() {
    _medication.takenDates ??= [];
    _medication.missedDates ??= [];
    _medication.dailyTakenTimes ??= {};
    _medication.dailyMissedTimes ??= {};
  }

  void _calculateDates() {
    currentDate = DateTime.now();
    startDate = _medication.startTime!.toDate();
    endDate = _medication.endTime!.toDate();
    currentDay = currentDate.isBefore(startDate)
        ? 0
        : currentDate.difference(startDate).inDays + 1;
    isExpired = currentDate.isAfter(endDate);
    totalDays = endDate.difference(startDate).inDays + 1;
    progressValue = currentDay / totalDays;
  }

  Future<void> _markAsTaken(TimeOfDay? time) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    setState(() {
      if (!_medication.takenDates!.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day)) {
        _medication.takenDates!.add(today);
      }

      _medication.missedDates!.removeWhere((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);

      if (time != null) {
        _medication.dailyTakenTimes!.putIfAbsent(todayKey, () => []);
        if (!_medication.dailyTakenTimes![todayKey]!
            .any((t) => t.hour == time.hour && t.minute == time.minute)) {
          _medication.dailyTakenTimes![todayKey]!.add(time);
        }

        _medication.dailyMissedTimes![todayKey]?.removeWhere(
            (t) => t.hour == time.hour && t.minute == time.minute);
      }
    });

    await _firestore
        .collection('MedicationTracker')
        .doc(_medication.id)
        .update({
      'takenDates':
          _medication.takenDates!.map((e) => Timestamp.fromDate(e)).toList(),
      'missedDates':
          _medication.missedDates?.map((e) => Timestamp.fromDate(e)).toList(),
      'dailyTakenTimes': _medication.dailyTakenTimes?.map((key, value) =>
          MapEntry(key,
              value.map((e) => {'hour': e.hour, 'minute': e.minute}).toList())),
      'dailyMissedTimes': _medication.dailyMissedTimes?.map((key, value) =>
          MapEntry(key,
              value.map((e) => {'hour': e.hour, 'minute': e.minute}).toList())),
    });

    toast("Medication marked as taken");
    setState(() {}); // Refresh UI
  }

  Future<void> _markAsMissed(TimeOfDay time) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    setState(() {
      if (!_medication.missedDates!.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day)) {
        _medication.missedDates!.add(today);
      }

      _medication.dailyMissedTimes!.putIfAbsent(todayKey, () => []);
      if (!_medication.dailyMissedTimes![todayKey]!
          .any((t) => t.hour == time.hour && t.minute == time.minute)) {
        _medication.dailyMissedTimes![todayKey]!.add(time);
      }
    });

    await _firestore
        .collection('MedicationTracker')
        .doc(_medication.id)
        .update({
      'missedDates':
          _medication.missedDates?.map((e) => Timestamp.fromDate(e)).toList(),
      'dailyMissedTimes': _medication.dailyMissedTimes?.map((key, value) =>
          MapEntry(key,
              value.map((e) => {'hour': e.hour, 'minute': e.minute}).toList())),
    });

    toast("Medication marked as missed");
    setState(() {}); // Refresh UI
  }

  Widget _buildDoseTimeButton(TimeOfDay? time, String label) {
    if (time == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final isTaken = _medication.dailyTakenTimes?[todayKey]
            ?.any((t) => t.hour == time.hour && t.minute == time.minute) ??
        false;
    final isMissed = _medication.dailyMissedTimes?[todayKey]
            ?.any((t) => t.hour == time.hour && t.minute == time.minute) ??
        false;
    final isPastDue = now.hour > time.hour ||
        (now.hour == time.hour && now.minute > time.minute);
    final isFutureDose = now.hour < time.hour ||
        (now.hour == time.hour && now.minute < time.minute);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        color: context.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _getDoseIcon(label),
                    color: _getDoseColor(label),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: boldTextStyle(size: 16),
                        ),
                        Text(
                          formatTimeOfDay(time),
                          style: secondaryTextStyle(),
                        ),
                      ],
                    ),
                  ),
                  if (isTaken)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 28)
                  else if (isMissed)
                    const Icon(Icons.warning_amber,
                        color: Colors.orange, size: 28)
                ],
              ),
              if (!isTaken && !isMissed && !isFutureDose)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _markAsTaken(time),
                          child: const Text(
                            'Mark as Taken',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _markAsMissed(time),
                          child: const Text(
                            'Mark as Missed',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isFutureDose && !isTaken && !isMissed)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Next dose at ${formatTimeOfDay(time)}',
                    style: secondaryTextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDoseColor(String label) {
    switch (label) {
      case 'Morning':
        return Colors.blue;
      case 'Mid Day':
        return Colors.orange;
      case 'Evening':
        return Colors.purple;
      default:
        return kPrimary;
    }
  }

  IconData _getDoseIcon(String label) {
    switch (label) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Mid Day':
        return Icons.sunny;
      case 'Evening':
        return Icons.nightlight_round;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildProgressSummary() {
    final completedDays = _medication.takenDates?.length ?? 0;
    final missedDays = _medication.missedDates?.length ?? 0;
    final completionRate = _calculateCompletionRate();

    // Calculate today's taken and missed doses
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayTaken = _medication.dailyTakenTimes?[todayKey]?.length ?? 0;
    final todayMissed = _medication.dailyMissedTimes?[todayKey]?.length ?? 0;

    // Calculate total taken and missed doses across all days
    int totalTaken = 0;
    int totalMissed = 0;

    _medication.dailyTakenTimes?.forEach((key, value) {
      totalTaken += value.length;
    });

    _medication.dailyMissedTimes?.forEach((key, value) {
      totalMissed += value.length;
    });

    return Card(
      elevation: 2,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Treatment Progress',
              style: boldTextStyle(size: 18, color: kPrimary),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                color: kPrimary,
                value: progressValue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isExpired
                      ? "Treatment Completed"
                      : "Day $currentDay of $totalDays",
                  style: secondaryTextStyle(
                      size: 14, color: isExpired ? Colors.green : null),
                ),
                Text(
                  '$completionRate% Complete',
                  style: boldTextStyle(color: kPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Today's dose summary
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Today's Doses",
                style: boldTextStyle(size: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Taken Today', todayTaken.toString(), Colors.green),
                _buildStatItem(
                    'Missed Today', todayMissed.toString(), Colors.orange),
                _buildStatItem(
                    'Remaining Today',
                    (_countTotalDailyDoses() - todayTaken - todayMissed)
                        .toString(),
                    Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            // Total dose summary
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "All Doses",
                style: boldTextStyle(size: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Total Taken', totalTaken.toString(), Colors.green),
                _buildStatItem(
                    'Total Missed', totalMissed.toString(), Colors.orange),
                _buildStatItem(
                    'Total Remaining',
                    ((totalDays * _countTotalDailyDoses()) -
                            totalTaken -
                            totalMissed)
                        .toString(),
                    Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            // Day summary
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Days Summary",
                style: boldTextStyle(size: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Completed Days', completedDays.toString(), Colors.green),
                _buildStatItem(
                    'Missed Days', missedDays.toString(), Colors.red),
                _buildStatItem(
                    'Remaining Days',
                    (totalDays - completedDays - missedDays).toString(),
                    Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Helper function to count total daily doses
  int _countTotalDailyDoses() {
    int count = 0;
    if (_medication.morning != null) count++;
    if (_medication.midDay != null) count++;
    if (_medication.evening != null) count++;
    return count;
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: boldTextStyle(color: color),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: secondaryTextStyle(size: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  String _calculateCompletionRate() {
    final completedDays = _medication.takenDates?.length ?? 0;
    return ((completedDays / totalDays) * 100).toStringAsFixed(1);
  }

  Widget _buildMedicationInfoCard() {
    return Card(
      elevation: 2,
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Details',
              style: boldTextStyle(size: 18, color: kPrimary),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _medication.name ?? 'Not specified'),
            _buildInfoRow(
                'Instructions', _medication.prescription ?? 'Not specified'),
            _buildInfoRow(
              'Treatment Period',
              '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: primaryTextStyle(size: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: primaryTextStyle(size: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    backButton(context),
                    Text(
                      "Medication Tracker",
                      style: boldTextStyle(color: kPrimary),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMedicationInfoCard(),
                const SizedBox(height: 20),
                Text(
                  "Today's Medication Schedule",
                  style: boldTextStyle(size: 18, color: kPrimary),
                ),
                const SizedBox(height: 12),
                _buildDoseTimeButton(_medication.morning, 'Morning'),
                _buildDoseTimeButton(_medication.midDay, 'Mid Day'),
                _buildDoseTimeButton(_medication.evening, 'Evening'),
                const SizedBox(height: 20),
                _buildProgressSummary(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

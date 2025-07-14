import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/controllers/MedicationController.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:intl/intl.dart';

import '../../component/backButton.dart';
import '../../constant/color.dart';
import '../../models/MedicationModel.dart';
import '../../services/formatTime.dart';

class MedicationSummaryScreen extends StatefulWidget {
  final MedicationModel medication;
  const MedicationSummaryScreen({super.key, required this.medication});

  @override
  State<MedicationSummaryScreen> createState() =>
      _MedicationSummaryScreenState();
}

class _MedicationSummaryScreenState extends State<MedicationSummaryScreen> {
  final MedicationController medicationController =
      Get.put(MedicationController());
  bool isChecked = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: backButton(context),
        title: Text("Medication Summary", style: TextStyle(color: kPrimary)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Medication Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(
                      label: "Medication Name",
                      value: widget.medication.name!,
                    ),
                    _buildSummaryItem(
                      label: "Treatment Period",
                      value:
                          "${DateFormat('MMM dd, yyyy').format(widget.medication.startTime!.toDate())} - ${DateFormat('MMM dd, yyyy').format(widget.medication.endTime!.toDate())}",
                    ),
                    if (widget.medication.morning != null)
                      _buildSummaryItem(
                        label: "Morning Dose",
                        value: formatTimeOfDay(widget.medication.morning!),
                      ),
                    if (widget.medication.midDay != null)
                      _buildSummaryItem(
                        label: "Mid Day Dose",
                        value: formatTimeOfDay(widget.medication.midDay!),
                      ),
                    if (widget.medication.evening != null)
                      _buildSummaryItem(
                        label: "Evening Dose",
                        value: formatTimeOfDay(widget.medication.evening!),
                      ),
                    _buildSummaryItem(
                      label: "Instructions",
                      value: widget.medication.prescription!,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Consent Checkbox
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: isChecked,
                        activeColor: kPrimary,
                        onChanged: (value) {
                          setState(() => isChecked = value ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "I consent to receive notifications about my medication schedule. I understand that missing doses may affect treatment effectiveness.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked ? kPrimary : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed:
                    isChecked && !_isSubmitting ? _submitMedication : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Save Medication",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _submitMedication() async {
    setState(() => _isSubmitting = true);
    try {
      await medicationController.handleCreateMedication(widget.medication);
      Get.off(() => const MedicationTracker());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving medication: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

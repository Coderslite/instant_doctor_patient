import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:nb_utils/nb_utils.dart';

class SymptomSelector extends StatelessWidget {
  final Set<String> selectedSymptoms;
  final TextEditingController complaintController;
  final Function(String) onSymptomToggled;

  const SymptomSelector({
    super.key,
    required this.selectedSymptoms,
    required this.complaintController,
    required this.onSymptomToggled,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> commonSymptoms = [
      "Fever", "Headache", "Cough", "Fatigue",
      "Stomach Pain", "Nausea", "Dizziness", "Rash",
      "Sore Throat", "Chest Pain", "Back Pain", "Vomiting"
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptoms & Details',
          style: boldTextStyle(size: 22, color: ink, letterSpacing: -0.5),
        ),
        8.height,
        Text(
          'Help the doctor understand your condition better.',
          style: secondaryTextStyle(size: 13, color: slate, height: 1.4),
        ),
        24.height,

        Text(
          'Select Symptoms',
          style: boldTextStyle(size: 15, color: ink),
        ),
        16.height,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: commonSymptoms.map((symptom) {
            final isSelected = selectedSymptoms.contains(symptom);

            return GestureDetector(
              onTap: () => onSymptomToggled(symptom),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? kPrimary : border,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Text(
                  symptom,
                  style: boldTextStyle(
                    size: 13,
                    color: isSelected ? white : ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        24.height,
        Text(
          'Additional Complaint',
          style: boldTextStyle(size: 15, color: ink),
        ),
        12.height,
        TextField(
          controller: complaintController,
          maxLines: 5,
          style: primaryTextStyle(color: ink),
          decoration: InputDecoration(
            hintText: 'Describe your symptoms in detail...',
            hintStyle: secondaryTextStyle(color: slate.withOpacity(0.4), size: 14),
            fillColor: white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/screens/medication/MedicationTracker.dart';
import 'package:intl/intl.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/formatTime.dart';
import 'package:instant_doctor/models/MedicationModel.dart';
import 'package:nb_utils/nb_utils.dart';
import 'MedicationSummary.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String prescription = '';
  Timestamp? startTime;
  Timestamp? endTime;
  TimeOfDay? morning;
  TimeOfDay? midDay;
  TimeOfDay? evening;
  bool isLoading = false;

  // New state for frequency selection
  List<bool> frequencySelection = [
    false,
    false,
    false
  ]; // Morning, Midday, Evening
  final List<String> frequencyLabels = ['Morning', 'Mid Day', 'Evening'];
  final List<TimeOfDay?> frequencyTimes = [null, null, null];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Card(
          color: context.cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: kPrimary,
            ),
          ).onTap(() {
            Get.off(MedicationTracker());
          }),
        ),
        title: Text("Add Medication", style: TextStyle(color: kPrimary)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Info Card
              _buildSectionCard(
                title: "Medication Information",
                children: [
                  _buildInputField(
                    label: "Medication Name",
                    hint: "e.g. Ibuprofen",
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required field" : null,
                    onChanged: (value) => name = value,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: "Instructions",
                    hint: "e.g. Take 2 pills with water after meals",
                    validator: (value) =>
                        value?.isEmpty ?? true ? "Required field" : null,
                    onChanged: (value) => prescription = value,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Schedule Card
              _buildSectionCard(
                title: "Medication Schedule",
                children: [
                  // Date Range Picker
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: "Start Date",
                          value: startTime?.toDate(),
                          onSelected: (date) {
                            setState(() {
                              startTime = Timestamp.fromDate(date);
                              // Auto-set end date to 1 week later if not set
                              endTime ??= Timestamp.fromDate(
                                    date.add(const Duration(days: 3)));
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                          label: "End Date",
                          value: endTime?.toDate(),
                          onSelected: (date) {
                            setState(() => endTime = Timestamp.fromDate(
                                DateTime(date.year, date.month, date.day, 23,
                                    59, 59, 999)));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Frequency Selection
                  Text("Dosage Times", style: boldTextStyle(size: 24)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(3, (index) {
                      return ChoiceChip(
                        label: Text(frequencyLabels[index]),
                        selected: frequencySelection[index],
                        onSelected: (selected) {
                          setState(() {
                            frequencySelection[index] = selected;
                            if (selected && frequencyTimes[index] == null) {
                              // Set default time if none selected
                              frequencyTimes[index] = TimeOfDay(
                                hour: index == 0
                                    ? 8
                                    : index == 1
                                        ? 12
                                        : 18,
                                minute: 0,
                              );
                              _updateTimeFields();
                            } else if (!selected) {
                              frequencyTimes[index] = null;
                              _updateTimeFields();
                            }
                          });
                        },
                        selectedColor: kPrimary,
                        labelStyle: TextStyle(
                          color: frequencySelection[index]
                              ? Colors.white
                              : Colors.black,
                        ),
                      );
                    }),
                  ),

                  // Time Pickers for selected frequencies
                  if (frequencySelection.any((element) => element)) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(3, (index) {
                        if (!frequencySelection[index]) {
                          return const SizedBox.shrink();
                        }

                        return _buildTimePicker(
                          label: frequencyLabels[index],
                          time: frequencyTimes[index],
                          onSelected: (time) {
                            setState(() {
                              frequencyTimes[index] = time;
                              _updateTimeFields();
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // primary: kPrimary,
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _validateAndContinue,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Continue",
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
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
        elevation: 2,
        color: context.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ));
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          style: primaryTextStyle(),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: context.cardColor,
          ),
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: kPrimary,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              ),
            );
            if (date != null) onSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: context.cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? DateFormat('MMM dd, yyyy').format(value)
                      : "Select Date",
                  style: primaryTextStyle(
                    size: 14,
                    color: value != null ? null : Colors.grey,
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: kPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required Function(TimeOfDay) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: kPrimary,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              ),
            );
            if (selectedTime != null) onSelected(selectedTime);
          },
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: context.cardColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time != null ? formatTimeOfDay(time) : "Select Time",
                  style: primaryTextStyle(
                    size: 14,
                    color: time != null ? null : Colors.grey,
                  ),
                ),
                Icon(Icons.access_time, size: 18, color: kPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _updateTimeFields() {
    setState(() {
      morning = frequencyTimes[0];
      midDay = frequencyTimes[1];
      evening = frequencyTimes[2];
    });
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    if (startTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select a start date")));
      return;
    }

    if (endTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select an end date")));
      return;
    }

    if (!frequencySelection.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select at least one dosage time")));
      return;
    }

    setState(() => isLoading = true);

    final medication = MedicationModel(
      id: Timestamp.now().toString(),
      userId: userController.userId.value,
      name: name,
      prescription: prescription,
      startTime: startTime,
      endTime: endTime,
      morning: morning,
      midDay: midDay,
      evening: evening,
      interval: 0,
      createdAt: Timestamp.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationSummaryScreen(medication: medication),
      ),
    ).then((_) => setState(() => isLoading = false));
  }
}

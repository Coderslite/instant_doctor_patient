import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart';
import '../../controllers/BookingController.dart';
import '../../services/AppointmentService.dart';
import '../../services/formatDate.dart';
import '../../services/formatDuration.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({super.key});

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  final bookingController = Get.find<BookingController>();
  final appointmentService = Get.find<AppointmentService>();
  final _formKey = GlobalKey<FormState>();
  final _controller = EasyInfiniteDateTimelineController();

  int _currentStep = 0;
  TimeOfDay? _selectedTime;
  bool isLoading = true;
  List<Appointmentpricingmodel> price = [];

  final List<String> _commonComplaints = [
    'Fever and chills',
    'Headache',
    'Cough and cold',
    'Stomach pain',
    'Back pain',
    'Skin rash',
    'Allergy symptoms',
    'Difficulty breathing',
    'Joint pain',
    'Fatigue and weakness'
  ];

  String _selectedComplaint = '';
  final TextEditingController _complainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    _complainController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    price = await appointmentService.getAppointmentPrice();
    setState(() => isLoading = false);
  }

  bool _validateStep1() => bookingController.package.value.isNotEmpty;
  bool _validateStep2() =>
      bookingController.selectedDate.isAfter(DateTime.now());

  void _confirmBooking() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text("New Appointment", style: boldTextStyle()),
                  Container(),
                ],
              ),
              Expanded(
                child: KeyboardDismisser(
                  child: Form(
                    key: _formKey,
                    child: Stepper(
                      currentStep: _currentStep,
                      connectorColor: WidgetStatePropertyAll(kPrimary),
                      onStepContinue: () {
                        if (_currentStep == 0 && !_validateStep1()) return;
                        if (_currentStep == 1 && !_validateStep2()) return;
                        if (_currentStep < 3) {
                          // Changed from 2 to 3 for new step
                          setState(() => _currentStep += 1);
                        } else {
                          _confirmBooking();
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep -= 1);
                        }
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              if (_currentStep != 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: details.onStepCancel,
                                    child: Text(
                                      'Back',
                                      style: primaryTextStyle(),
                                    ),
                                  ),
                                ),
                              if (_currentStep != 0) SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimary,
                                  ),
                                  child: Text(
                                    _currentStep == 3
                                        ? 'Confirm Booking'
                                        : 'Next', // Changed from 2 to 3
                                    style: TextStyle(color: white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: [
                        _buildPackageStep(),
                        _buildDateTimeStep(),
                        _buildDetailsStep(),
                        _buildSummaryStep(), // New summary step
                      ],
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

  Step _buildPackageStep() {
    return Step(
      title: Text(
        'Select Package',
        style: boldTextStyle(size: 16),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your consultation package',
            style: secondaryTextStyle(),
          ),
          SizedBox(height: 16),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: price.map((e) {
                    final isSelected =
                        bookingController.package.value == e.name;
                    return ChoiceChip(
                      color: WidgetStatePropertyAll(
                          isSelected ? kPrimary : context.cardColor),
                      label: Text(
                        '${e.name}\n${formatAmount(e.amount.validate())}',
                        textAlign: TextAlign.center,
                        style:
                            primaryTextStyle(color: isSelected ? white : null),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          bookingController.duration.value =
                              e.duration.validate();
                          bookingController.price.value = e.amount.validate();
                          bookingController.package.value = e.name.validate();
                          setState(() {});
                        }
                      },
                      selectedColor: kPrimary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? kPrimary : null,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
          if (!_validateStep1() && _currentStep == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Please select a package',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDateTimeStep() {
    return Step(
      title: Text(
        'Date & Time',
        style: boldTextStyle(size: 16),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select appointment date', style: secondaryTextStyle()),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            color: context.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: EasyInfiniteDateTimeLine(
                controller: _controller,
                firstDate: DateTime.now(),
                showTimelineHeader: false,
                dayProps: EasyDayProps(
                  inactiveDayNumStyle: primaryTextStyle(),
                  inactiveDayStrStyle: primaryTextStyle(),
                  inactiveMothStrStyle: primaryTextStyle(size: 12),
                  inactiveDayStyle: DayStyle(
                    decoration: BoxDecoration(
                      color: gray.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  todayNumStyle: primaryTextStyle(color: kPrimary),
                  todayMonthStrStyle: boldTextStyle(color: kPrimary),
                  activeDayStyle: DayStyle(
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                selectionMode: SelectionMode.alwaysFirst(),
                focusDate: bookingController.selectedDate,
                lastDate: DateTime.now().add(Duration(days: 14)),
                onDateChange: (selectedDate) {
                  setState(() {
                    bookingController.selectedDate = selectedDate;
                    _selectedTime = null; // Reset time when date changes
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Text('Select appointment time', style: secondaryTextStyle()),
          SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: kPrimary,
                        // onSurface: context.textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: context.cardColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() {
                  _selectedTime = time;
                  final date = bookingController.selectedDate;
                  bookingController.selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedTime == null
                        ? 'Select a time'
                        : _selectedTime!.format(context),
                    style: boldTextStyle(),
                  ),
                  Icon(Icons.access_time, color: kPrimary),
                ],
              ),
            ),
          ),
          if (!_validateStep2() && _currentStep == 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Please select a valid future date and time',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDetailsStep() {
    return Step(
      title: Text(
        'Symptoms',
        style: boldTextStyle(size: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: context.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Describe your symptoms',
                            style: boldTextStyle(size: 14)),
                        if (_complainController.text.isNotEmpty)
                          IconButton(
                            icon:
                                Icon(Icons.clear, size: 20, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _complainController.clear();
                                _selectedComplaint = '';
                                bookingController.complain.value =
                                    ''; // Clear controller value too
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_selectedComplaint.isEmpty) ...[
                      Text(
                        'Common complaints:',
                        style: secondaryTextStyle(size: 12),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonComplaints.map((complaint) {
                          return ActionChip(
                            label: Text(complaint),
                            onPressed: () {
                              setState(() {
                                _selectedComplaint = complaint;
                                _complainController.text =
                                    "• Main Symptom: $complaint\n\n";
                                bookingController.complain.value =
                                    _complainController
                                        .text; // Update controller
                              });
                            },
                            backgroundColor: kPrimary.withOpacity(0.1),
                            labelStyle: boldTextStyle(
                              size: 12,
                              color: kPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _complainController,
                      maxLines: 8,
                      style: primaryTextStyle(),
                      decoration: InputDecoration(
                        hintText: _selectedComplaint.isEmpty
                            ? 'Describe your symptoms in detail...'
                            : 'Provide details about your $_selectedComplaint...',
                        hintStyle: secondaryTextStyle(),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: context.cardColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe your symptoms';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        bookingController.complain.value =
                            value; // Update on typing
                        setState(() {});
                      },
                    ),
                    if (_selectedComplaint.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        'Add details:',
                        style: boldTextStyle(size: 12, color: kPrimary),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (!_complainController.text.contains('• Duration:'))
                            _buildDetailPrompt('• Duration: '),
                          if (!_complainController.text
                              .contains('• Severity (1-10):'))
                            _buildDetailPrompt('• Severity (1-10): '),
                          if (!_complainController.text
                              .contains('• When started:'))
                            _buildDetailPrompt('• When started: '),
                          if (!_complainController.text
                              .contains('• Worse with:'))
                            _buildDetailPrompt('• Worse with: '),
                          if (!_complainController.text
                              .contains('• Better with:'))
                            _buildDetailPrompt('• Better with: '),
                          if (!_complainController.text
                              .contains('• Other symptoms:'))
                            _buildDetailPrompt('• Other symptoms: '),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Example format:\n\n• Main Symptom: Headache\n• Duration: 2 days\n• Severity (1-10): 7/10\n• When started: Yesterday\n• Worse with: Bright lights\n• Better with: Rest',
                        style: secondaryTextStyle(size: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildDetailPrompt(String text) {
    return GestureDetector(
      onTap: () {
        final newText = '${_complainController.text}\n$text';
        _complainController.text = newText;
        bookingController.complain.value = newText; // Update controller value
        _complainController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        setState(() {});
      },
      child: Chip(
        label: Text(text.replaceFirst('• ', '')),
        backgroundColor: kPrimary.withOpacity(0.1),
        labelStyle: secondaryTextStyle(size: 12, color: kPrimary),
      ),
    );
  }

  // New summary step
  Step _buildSummaryStep() {
    return Step(
      title: Text(
        'Summary',
        style: boldTextStyle(size: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 2,
              color: context.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appointment Details', style: boldTextStyle(size: 14)),
                    SizedBox(height: 12),
                    _buildSummaryRow(
                        'Package', bookingController.package.value),
                    _buildSummaryRow(
                        'Date', formatDate(bookingController.selectedDate)),
                    _buildSummaryRow(
                        'Duration',
                        formatDuration(Duration(
                            seconds: bookingController.duration.value))),
                    Divider(),
                    Text('Estimated Cost', style: boldTextStyle(size: 14)),
                    SizedBox(height: 8),
                    _buildSummaryRow('Consultation Fee',
                        formatAmount(bookingController.price.value)),
                    SizedBox(height: 8),
                    Text(
                      'Total amount will be charged after appointment confirmation',
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              color: context.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Symptoms', style: boldTextStyle(size: 14)),
                    SizedBox(height: 8),
                    Text(
                      _complainController.text.isNotEmpty
                          ? _complainController.text
                          : 'No symptoms described',
                      style: primaryTextStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 3,
      state: StepState.indexed,
    );
  }

// Make the guidelines more compact
  Widget _buildSymptomGuidelines() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('How to describe symptoms effectively',
          style: boldTextStyle(size: 12, color: kPrimary)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Duration: How long have symptoms lasted',
                  style: secondaryTextStyle(size: 12)),
              Text('• Severity: Rate pain/discomfort (1-10)',
                  style: secondaryTextStyle(size: 12)),
              Text('• Pattern: Constant or intermittent',
                  style: secondaryTextStyle(size: 12)),
              Text('• Triggers: What makes it better/worse',
                  style: secondaryTextStyle(size: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      color: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Package', bookingController.package.value),
            _buildSummaryRow(
                'Date', formatDate(bookingController.selectedDate)),
            _buildSummaryRow(
                'Duration',
                formatDuration(
                    Duration(seconds: bookingController.duration.value))),
            _buildSummaryRow(
                'Price', formatAmount(bookingController.price.value)),
            Divider(),
            _buildSummaryRow(
                'Total', formatAmount(bookingController.price.value),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal ? boldTextStyle() : primaryTextStyle(size: 14)),
          Text(value,
              style: isTotal
                  ? boldTextStyle(color: kPrimary, size: 16)
                  : secondaryTextStyle(size: 14)),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Appointment',
          style: boldTextStyle(size: 26),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please confirm your appointment details:'),
            SizedBox(height: 16),
            _buildSummaryCard(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: primaryTextStyle(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await bookingController.handleBookAppointment(
                    doctorId: '', context: context);
              } catch (e) {
                errorSnackBar(title: e.toString());
              }
            },
            child: Text('Confirm', style: TextStyle(color: white)),
          ),
        ],
      ),
    );
  }
}

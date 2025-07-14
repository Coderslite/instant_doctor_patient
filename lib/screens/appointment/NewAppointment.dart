import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant/color.dart'; // Corrected import
import '../../controllers/BookingController.dart';
import '../../controllers/SettingController.dart';
import '../../services/AppointmentService.dart';
import '../../services/formatDate.dart';
import '../../services/formatDuration.dart';

class NewAppointment extends StatefulWidget {
  const NewAppointment({
    super.key,
  });

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  final bookingController = Get.find<BookingController>();
  final appointmentService = Get.find<AppointmentService>();
  final settingsController = Get.find<SettingsController>();
  final _formKey = GlobalKey<FormState>();
  final _controller = EasyInfiniteDateTimelineController();
  final _complainController = TextEditingController();

  int _currentStep = 0;
  TimeOfDay? _selectedTime;
  bool isLoading = true;
  List<Appointmentpricingmodel> price = [];
  bool _isTrialSelected = false;

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

  @override
  void initState() {
    super.initState();
    _loadPrices();
    if (settingsController.trialAvailable.value) {
      _isTrialSelected = true;
      bookingController.package.value = "Trial Consultation";
    }
  }

  @override
  void dispose() {
    _complainController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    price = await appointmentService.getAppointmentPrice();
    if (settingsController.trialAvailable.value) {
      price = price.where((p) => p.name == "Trial Consultation").toList();
    }
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
      body: Obx(
        () => Stack(
          alignment: Alignment.center,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        backButton(context),
                        Text("New Appointment", style: boldTextStyle()),
                        if (settingsController.trialAvailable.value ||
                            _isTrialSelected)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "TRIAL VERSION",
                              style:
                                  boldTextStyle(size: 12, color: Colors.green),
                            ),
                          ),
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
                              if (_currentStep == 0 && !_validateStep1()) {
                                return;
                              }
                              if (_currentStep == 1 && !_validateStep2()) {
                                return;
                              }
                              if (_currentStep < 3) {
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
                                              : 'Next',
                                          style: TextStyle(color: white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).visible(!bookingController.isLoading.value);
                            },
                            steps: [
                              _buildPackageStep(),
                              _buildDateTimeStep(),
                              _buildDetailsStep(),
                              _buildSummaryStep(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child:
                  Loader().center().visible(bookingController.isLoading.value),
            )
          ],
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
          if (settingsController.trialAvailable.value) ...[
            Card(
              elevation: 2,
              color: context.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Version',
                      style: boldTextStyle(size: 14, color: kPrimary),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isTrialSelected
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isTrialSelected
                                    ? Colors.green
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                if (_isTrialSelected)
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTrialSelected = true;
                                  // Select first trial package by default
                                  final trialPackage = price.firstWhereOrNull(
                                      (p) => p.name == "Trial Consultation");
                                  if (trialPackage != null) {
                                    bookingController.package.value =
                                        trialPackage.name.validate();
                                    bookingController.duration.value =
                                        trialPackage.duration.validate();
                                    bookingController.price.value =
                                        trialPackage.amount.validate();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: _isTrialSelected
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Trial Version',
                                    style: boldTextStyle(
                                      size: 14,
                                      color: _isTrialSelected
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: !_isTrialSelected
                                  ? kPrimary.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !_isTrialSelected
                                    ? kPrimary
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                if (!_isTrialSelected)
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isTrialSelected = false;
                                  // Select first non-trial package by default
                                  final paidPackage = price.firstWhereOrNull(
                                      (p) => p.name != "Trial Consultation");
                                  if (paidPackage != null) {
                                    bookingController.package.value =
                                        paidPackage.name.validate();
                                    bookingController.duration.value =
                                        paidPackage.duration.validate();
                                    bookingController.price.value =
                                        paidPackage.amount.validate();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: !_isTrialSelected
                                        ? kPrimary
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Paid Version',
                                    style: boldTextStyle(
                                      size: 14,
                                      color: !_isTrialSelected
                                          ? kPrimary
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
          if (_isTrialSelected || settingsController.trialAvailable.value)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.green.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Trial Version Benefits",
                        style: boldTextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Free 1 day consultation\n"
                    "• Available one time only\n"
                    "• Limited to one trial per user",
                    style: primaryTextStyle(),
                  ),
                ],
              ),
            ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: price
                      .where((e) => _isTrialSelected ||
                              settingsController.trialAvailable.value
                          ? e.name == "Trial Consultation"
                          : e.name != "Trial Consultation")
                      .map((e) {
                    final isSelected =
                        bookingController.package.value == e.name;
                    return ChoiceChip(
                      color: WidgetStatePropertyAll(isSelected
                          ? (_isTrialSelected ||
                                  settingsController.trialAvailable.value
                              ? Colors.green
                              : kPrimary)
                          : context.cardColor),
                      label: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${e.name}\n${formatAmount(e.amount.validate())}',
                                  textAlign: TextAlign.center,
                                  style: primaryTextStyle(
                                      color: isSelected ? white : null),
                                ),
                                Text(
                                  formatAmount(e.amount.validate()),
                                  style: secondaryTextStyle(),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                      selectedColor: _isTrialSelected ||
                              settingsController.trialAvailable.value
                          ? Colors.green.withOpacity(0.8)
                          : kPrimary.withOpacity(0.8),
                      labelStyle: TextStyle(
                        color: isSelected ? white : Colors.black,
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
                    _selectedTime = null;
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
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: context.cardColor,
                      ),
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true, // Force 24-hour format
                      ),
                      child: child!,
                    ),
                  );
                },
              );
              if (time != null && mounted) {
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
                        : _selectedTime!
                            .format(context)
                            .replaceAll(' AM', '')
                            .replaceAll(' PM', ''), // Remove AM/PM
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
                                bookingController.complain.value = '';
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
                                    _complainController.text;
                              });
                            },
                            backgroundColor: context.cardColor,
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
                        bookingController.complain.value = value;
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
        bookingController.complain.value = newText;
        _complainController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        setState(() {});
      },
      child: Chip(
        label: Text(text.replaceFirst('• ', '')),
        backgroundColor: context.cardColor,
        labelStyle: secondaryTextStyle(size: 12, color: kPrimary),
      ),
    );
  }

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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? boldTextStyle() : primaryTextStyle(size: 14),
          ),
          Text(
            value,
            style: isTotal
                ? boldTextStyle(color: kPrimary, size: 16)
                : secondaryTextStyle(size: 14),
          ),
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
        backgroundColor: context.cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please confirm your appointment details:',
              style: secondaryTextStyle(),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              color: context.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSummaryRow(
                        'Package', bookingController.package.value),
                    _buildSummaryRow(
                        'Date', formatDate(bookingController.selectedDate)),
                    _buildSummaryRow(
                        'Duration',
                        formatDuration(Duration(
                            seconds: bookingController.duration.value))),
                    _buildSummaryRow(
                        'Price', formatAmount(bookingController.price.value)),
                    Divider(),
                    _buildSummaryRow(
                        'Total', formatAmount(bookingController.price.value),
                        isTotal: true),
                  ],
                ),
              ),
            ),
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
                    isTrial: settingsController.trialAvailable.value ||
                        _isTrialSelected,
                    doctorId: '',
                    context: context);
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

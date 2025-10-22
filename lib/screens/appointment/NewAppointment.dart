import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/models/AppointmentPricingModel.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/show_location_required.dart';
import '../../constant/color.dart';
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

  int _currentStep = 0;
  TimeOfDay? _selectedTime;
  bool isLoading = true;
  List<Appointmentpricingmodel> price = [];
  bool _isTrialSelected = false;

  // Enhanced symptoms data structure
  final List<Map<String, dynamic>> _symptomsData = [
    {
      'name': 'Fever',
      'icon': Icons.thermostat,
    },
    {
      'name': 'Headache',
      'icon': Icons.sick,
    },
    {
      'name': 'Cough',
      'icon': Icons.air,
    },
    {
      'name': 'Stomach pain',
      'icon': Icons.emoji_food_beverage,
    },
    {
      'name': 'Fatigue',
      'icon': Icons.bedtime,
    },
    {
      'name': 'Skin rash',
      'icon': Icons.face_retouching_natural,
    },
    {
      'name': 'Joint pain',
      'icon': Icons.accessibility,
    },
    {
      'name': 'Shortness of breath',
      'icon': Icons.airline_seat_recline_normal,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (settingsController.trialAvailable.value) {
      _isTrialSelected = true;
      bookingController.package.value = "Trial Consultation";
    }
    handleInit();
  }

  handleInit() async {
    if (locationController.myCountry.value != 'null' &&
        locationController.myCountry.value.isNotEmpty) {
      print("not null");
      print(locationController.myCountry.value);
    } else {
      print("location is null");
      await handleShowRequestLocation(Get.context!);
    }
    _loadPrices();
    setState(() {});
  }

  @override
  void dispose() {
    bookingController.isLoading.value = false;
    super.dispose();
  }

  Future<void> _loadPrices() async {
    await Future.delayed(Duration(seconds: 1));
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
        () => StreamBuilder<UserModel>(
          stream: userService.getProfile(userId: userController.userId.value),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: kPrimary));
            }

            final data = snapshot.data!;
            final medicalProfileCompleted =
                data.bloodGroup.validate().isNotEmpty &&
                    data.height.validate().isNotEmpty &&
                    data.weight.validate().isNotEmpty &&
                    data.genotype.validate().isNotEmpty;

            if (!medicalProfileCompleted) {
              return Scaffold(
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with back button
                        Row(
                          children: [
                            backButton(context),
                            SizedBox(width: 16),
                            Text(
                              "New Appointment",
                              style: boldTextStyle(size: 20),
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        // Beautiful illustration
                        // Center(
                        //   child: Image.asset(
                        //     'assets/images/medical_profile.png', // Replace with your asset
                        //     height: 180,
                        //     fit: BoxFit.contain,
                        //   ),
                        // ),

                        // SizedBox(height: 32),

                        // Title with icon
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  size: 58,
                                  color: Colors.orange,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Complete Your Medical Profile",
                                style: boldTextStyle(size: 18),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Description text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "To book an appointment, we need some basic health information to help doctors provide you with the best care possible.",
                            textAlign: TextAlign.center,
                            style: primaryTextStyle(size: 14),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Missing information list
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMissingInfoItem(
                                  Icons.bloodtype,
                                  "Blood Group",
                                  data.bloodGroup.validate().isEmpty),
                              Divider(
                                height: 24,
                              ),
                              _buildMissingInfoItem(Icons.height, "Height",
                                  data.height.validate().isEmpty),
                              Divider(height: 24, color: Colors.grey[200]),
                              _buildMissingInfoItem(Icons.monitor_weight,
                                  "Weight", data.weight.validate().isEmpty),
                              Divider(height: 24, color: Colors.grey[200]),
                              _buildMissingInfoItem(Icons.medical_information,
                                  "Genotype", data.genotype.validate().isEmpty),
                            ],
                          ),
                        ),

                        Spacer(),

                        // Update button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              MedicalDataScreen().launch(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              "Update Medical Profile",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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

            return Stack(
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
                                  style: boldTextStyle(
                                      size: 12, color: Colors.green),
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
                                connectorColor:
                                    WidgetStatePropertyAll(kPrimary),
                                onStepContinue: () {
                                  if (_currentStep == 0 && !_validateStep1()) {
                                    return;
                                  }
                                  if (_currentStep == 1 && !_validateStep2()) {
                                    return;
                                  }
                                  if (_currentStep == 2) {
                                    if (bookingController
                                        .complain.value.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Please describe your condition'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
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
                                        if (_currentStep != 0)
                                          SizedBox(width: 8),
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
                                  _buildSymptomsStep(),
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
                  child: Loader()
                      .center()
                      .visible(bookingController.isLoading.value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Step _buildPackageStep() {
    bool isNigeria = locationController.myCountry.value == 'nigeria';
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
              ? Loader()
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
                                    '${e.name}\n${formatAmount(isNigeria ? e.amount.validate() : e.dollarAmount.validate())}',
                                    textAlign: TextAlign.center,
                                    style: primaryTextStyle(
                                        color: isSelected ? white : null),
                                  ),
                                  Text(
                                    formatAmount(isNigeria
                                        ? e.amount.validate()
                                        : e.dollarAmount.validate()),
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
                            bookingController.price.value = isNigeria
                                ? e.amount.validate()
                                : e.dollarAmount.validate();
                            bookingController.package.value = e.name.validate();
                            setState(() {});
                          }
                        },
                        selectedColor: _isTrialSelected ||
                                settingsController.trialAvailable.value
                            ? Colors.green.withOpacity(0.8)
                            : kPrimary.withOpacity(0.8),
                        labelStyle: boldTextStyle(size: 12));
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
                        alwaysUse24HourFormat: true,
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

  Step _buildSymptomsStep() {
    return Step(
      title: Text(
        'Health Information',
        style: boldTextStyle(size: 16),
      ),
      content: Form(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Row(
                        children: [
                          Icon(Icons.medical_services,
                              size: 20, color: kPrimary),
                          SizedBox(width: 8),
                          Text(
                            'Select Symptoms (Optional)',
                            style: boldTextStyle(size: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _symptomsData.map((symptom) {
                          final isSelected = bookingController.selectedSymptoms
                              .contains(symptom['name']);
                          return InputChip(
                            backgroundColor: context.cardColor,
                            label: Text(
                              symptom['name'],
                              style: primaryTextStyle(
                                  color: isSelected ? white : null),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  bookingController.selectedSymptoms
                                      .add(symptom['name']);
                                } else {
                                  bookingController.selectedSymptoms
                                      .remove(symptom['name']);
                                }
                              });
                            },
                            selectedColor: kPrimary,
                            checkmarkColor: kPrimary,
                            labelStyle: TextStyle(
                              color: isSelected ? kPrimary : textPrimaryColor,
                            ),
                            avatar: Icon(symptom['icon'],
                                size: 18,
                                color: isSelected ? kPrimary : Colors.grey),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
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
                      Row(
                        children: [
                          Icon(Icons.description, size: 20, color: kPrimary),
                          SizedBox(width: 8),
                          Text(
                            'Describe Your Condition *',
                            style: boldTextStyle(size: 14, color: kPrimary),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Example: "I have had a persistent cough for 3 days with mild fever...',
                        style: secondaryTextStyle(size: 12),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        maxLines: 5,
                        minLines: 3,
                        style: primaryTextStyle(size: 14),
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: secondaryTextStyle(size: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: kPrimary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: kPrimary),
                          ),
                          filled: true,
                          fillColor: context.scaffoldBackgroundColor,
                        ),
                        onChanged: (val) {
                          bookingController.complain.value = val;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe your condition for the doctor';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This information helps the doctor understand your situation better',
                        style: secondaryTextStyle(size: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: kPrimary),
                        SizedBox(width: 8),
                        Text(
                          'Appointment Details',
                          style: boldTextStyle(size: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildSummaryRow(
                        'Package:', bookingController.package.value),
                    _buildSummaryRow(
                        'Date:', formatDate(bookingController.selectedDate)),
                    _buildSummaryRow(
                        'Duration:',
                        formatDuration(Duration(
                            seconds: bookingController.duration.value))),
                    Divider(height: 24),
                    _buildSummaryRow('Consultation Fee:',
                        formatAmount(bookingController.price.value),
                        isTotal: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
                    Row(
                      children: [
                        Icon(Icons.medical_information,
                            size: 20, color: kPrimary),
                        SizedBox(width: 8),
                        Text(
                          'Health Information',
                          style: boldTextStyle(size: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (bookingController.selectedSymptoms.isNotEmpty) ...[
                      Text(
                        'Selected Symptoms:',
                        style: boldTextStyle(size: 12),
                      ),
                      SizedBox(height: 8),
                      ...bookingController.selectedSymptoms
                          .asMap()
                          .entries
                          .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: primaryTextStyle(size: 14)),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: primaryTextStyle(size: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 12),
                    ],
                    Text(
                      'Condition Description:',
                      style: boldTextStyle(size: 12),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bookingController.complain.value.isNotEmpty
                            ? bookingController.complain.value
                            : 'No description provided',
                        style: primaryTextStyle(),
                      ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal ? boldTextStyle(size: 14) : primaryTextStyle(size: 14),
          ),
          10.width,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: isTotal
                  ? boldTextStyle(size: 14, color: kPrimary)
                  : secondaryTextStyle(size: 14),
            ),
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
                bookingController.isLoading.value = true;
                setState(() {});

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

  Widget _buildMissingInfoItem(IconData icon, String label, bool isMissing) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMissing ? Colors.red[50] : Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isMissing ? Colors.red : Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: boldTextStyle(size: 16),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isMissing ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isMissing ? "Missing" : "Completed",
            style: TextStyle(
              color: isMissing ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

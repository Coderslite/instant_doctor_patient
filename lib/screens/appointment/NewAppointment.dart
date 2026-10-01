import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/BookingController.dart';
import 'package:instant_doctor/controllers/PaymentController.dart';
import 'package:instant_doctor/services/IAPService.dart';
import 'package:instant_doctor/services/PricingService.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

import 'widgets/BookingSchedule.dart';
import 'widgets/BookingSummary.dart';
import 'widgets/PackageSelection.dart';
import 'widgets/SymptomSelector.dart';

class NewAppointment extends StatefulWidget {
  final String? doctorId;
  final String? symptoms;

  const NewAppointment({super.key, this.doctorId, this.symptoms});

  @override
  State<NewAppointment> createState() => _NewAppointmentState();
}

class _NewAppointmentState extends State<NewAppointment> {
  final PageController _pageController = PageController();
  final BookingController _booking = Get.find<BookingController>();
  final PricingService pricingService = Get.find<PricingService>();
  final TextEditingController _complaintController = TextEditingController();

  int _currentStep = 0;
  dynamic
      _selectedProduct; // Changed to handle product ID (String) or IAP ProductDetails
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final Set<String> _selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    if (widget.symptoms != null) {
      _selectedSymptoms.add(widget.symptoms.validate());
    }
    if (widget.doctorId != null) {
      _booking.docId.value = widget.doctorId.validate();
    }
  }

  void _nextStep() {
    if (_booking.isLoading.value) return; // guard duplicate taps
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handlePayment();
    }
  }

  void _prevStep() {
    if (_booking.isLoading.value) return; // guard back during booking
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      finish(context);
    }
  }

  Future<void> _handlePayment() async {
    // Synchronize selected data with BookingController
    _booking.complain.value = _complaintController.text;
    _booking.selectedSymptoms.value = _selectedSymptoms.toList();

    // Get ID and Price
    final String productId =
        (_selectedProduct is String) ? _selectedProduct : _selectedProduct.id;
    final double finalPrice = (_selectedProduct is String)
        ? pricingService.getFinalPrice(productId)
        : _selectedProduct.rawPrice.toDouble();
    log("final price $finalPrice");
    _booking.price.value = finalPrice.toInt();
    _booking.package.value = pricingService.getPackageType(productId);

    // Get duration from product metadata
    final metadata = Get.find<IAPService>().getMetadata(productId);
    _booking.duration.value = metadata?['duration'] ?? 30 * 60;
    // Parse time string (e.g., "09:00 AM")
    final timeParts = _selectedTime!.split(' '); // ["09:00", "AM"]
    final hmParts = timeParts[0].split(':'); // ["09", "00"]
    int hour = int.parse(hmParts[0]);
    int minute = int.parse(hmParts[1]);
    final isPm = timeParts[1] == 'PM';

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    _booking.selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    // Final validation: Ensure the time hasn't passed while user was on other steps
    if (_booking.selectedDate
        .isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      errorSnackBar(
        context: context,
        title: "Time Slot Expired. Please choose a later slot.",
      );
      setState(() => _currentStep = 1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    // Trigger booking flow (creates pending appointment and shows payment bottom sheet)
    await _booking.handleBookAppointment(
      doctorId: _booking.docId.value,
      isTrial: false,
      isPaystack: false, // Not used anymore as bottom sheet handles selection
      context: context,
    );
  }

  bool _isNextEnabled() {
    if (_currentStep == 0) return _selectedProduct != null;
    if (_currentStep == 1) return _selectedTime != null;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageGray,
      body: Column(
        children: [
          _buildPremiumHeader(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  child: PackageSelection(
                    selectedProduct: _selectedProduct,
                    onSelected: (p) => setState(() => _selectedProduct = p),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  child: BookingSchedule(
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    onDateSelected: (d) => setState(() => _selectedDate = d),
                    onTimeSelected: (t) => setState(() => _selectedTime = t),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  child: SymptomSelector(
                    selectedSymptoms: _selectedSymptoms,
                    complaintController: _complaintController,
                    onSymptomToggled: (s) => setState(() {
                      _selectedSymptoms.contains(s)
                          ? _selectedSymptoms.remove(s)
                          : _selectedSymptoms.add(s);
                    }),
                  ),
                ),
                if (_selectedProduct != null && _selectedTime != null)
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                    child: BookingSummary(
                      selectedProduct: (_selectedProduct is String)
                          ? _selectedProduct
                          : (_selectedProduct?.id ?? ""),
                      selectedDate: _selectedDate,
                      selectedTime: _selectedTime!,
                      symptoms: _selectedSymptoms,
                      complaint: _complaintController.text,
                    ),
                  ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      color: obsidian,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _prevStep,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: white.withOpacity(0.12), width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: white, size: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Book Appointment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStepIndicator(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Bridge curve
          Container(
            height: 28,
            decoration: const BoxDecoration(
              color: pageGray,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final active = index <= _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: isCurrent ? 5 : 4,
            decoration: BoxDecoration(
              color: active ? kPrimary : white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              boxShadow: isCurrent
                  ? [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 8)]
                  : [],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: white,
        border: const Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: obsidian.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final paymentController = Get.find<PaymentController>();
          final loading = _booking.isLoading.value;
          final isPaying = paymentController.isLoading.value;
          return PremiumButton(
            onTap: loading || isPaying ? null : _nextStep,
            enabled: _isNextEnabled() && !loading && !isPaying,
            isLoading: loading || isPaying,
            text: _currentStep == 3 ? 'Confirm & Pay' : 'Continue',
          );
        }),
      ),
    );
  }
}

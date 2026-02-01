import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:instant_doctor/screens/refer/Refer.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/services/UserService.dart';
import 'package:instant_doctor/services/BaseService.dart';

class ApplyReferralProgramScreen extends StatefulWidget {
  const ApplyReferralProgramScreen({super.key});

  @override
  State<ApplyReferralProgramScreen> createState() =>
      _ApplyReferralProgramScreenState();
}

class _ApplyReferralProgramScreenState
    extends State<ApplyReferralProgramScreen> {
  final UserService _userService = Get.find<UserService>();

  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChecking = false;
  bool _isUsernameAvailable = false;
  bool _isSubmitting = false;
  String _checkingMessage = '';

  // Username validation regex
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    if (_usernameController.text.isEmpty) {
      toast("Please enter a username");
      return;
    }

    if (!_usernameRegex.hasMatch(_usernameController.text)) {
      toast(
          "Username must be 3-20 characters, letters, numbers, and underscore only");
      return;
    }

    setState(() {
      _isChecking = true;
      _checkingMessage = 'Checking availability...';
      _isUsernameAvailable = false;
    });

    try {
      await Future.delayed(
          Duration(milliseconds: 500)); // Simulate network delay

      // Check if username exists in Firestore
      final username = _usernameController.text.trim().toLowerCase();
      final user = await _userService.getUserByTag(tag: username);

      if (user == null) {
        setState(() {
          _isUsernameAvailable = true;
          _checkingMessage = '✅ Username is available!';
        });
      } else {
        setState(() {
          _isUsernameAvailable = false;
          _checkingMessage = '❌ Username already taken';
        });
      }
    } catch (e) {
      setState(() {
        _checkingMessage = 'Error checking username';
      });
      toast("Error checking username");
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _applyForReferralProgram() async {
    if (!_isUsernameAvailable) {
      toast("Please check and confirm username availability");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Update user's tag/username
      final newTag = _usernameController.text.trim().toLowerCase();
      await _userService.userCol.doc(userController.userId.value).update({
        "tag": newTag,
        "referralProgramApplied": true,
        "referralBalance": 0,
        "referralProgramAppliedAt": DateTime.now().millisecondsSinceEpoch,
      });

      toast("🎉 Referral program activated successfully!");

      // Update local user model
      userController.tag.value = newTag;
      userController.referralProgramApplied.value = true;
      ReferScreen().launch(context);
    } catch (e) {
      toast("Error applying for referral program: ${e.toString()}");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Apply for Referral Program",
          style: boldTextStyle(size: 20),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [kPrimary, Color(0xFF6C63FF)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.medal_star,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              24.height,

              // Title
              Text(
                "Become a Referral Partner",
                style: boldTextStyle(size: 24),
                textAlign: TextAlign.center,
              ).center(),

              8.height,

              Text(
                "Earn money by referring friends to Instant Doctor",
                style: secondaryTextStyle(size: 16, height: 1.5),
                textAlign: TextAlign.center,
              ).center(),

              32.height,

              // Benefits Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kPrimary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.gift, color: kPrimary),
                        12.width,
                        Text(
                          "Earning Benefits",
                          style: boldTextStyle(size: 18, color: kPrimary),
                        ),
                      ],
                    ),
                    16.height,
                    _buildBenefitItem(
                      "Instant Sign-up Bonus",
                      "Earn ₦50 for each new user who signs up with your code",
                    ),
                    _buildBenefitItem(
                      "Appointment Commission",
                      "Earn 10% of every payment made by users you referred",
                    ),
                    _buildBenefitItem(
                      "Withdraw Anytime",
                      "Withdraw your earnings directly to your bank account",
                    ),
                    _buildBenefitItem(
                      "Unlimited Earnings",
                      "No limit to how much you can earn",
                    ),
                  ],
                ),
              ),

              32.height,

              // Username Section
              Text(
                "Choose Your Referral Username",
                style: boldTextStyle(size: 18),
              ),

              8.height,

              Text(
                "This will be your unique referral code that others will use",
                style: secondaryTextStyle(),
              ),

              16.height,

              // Username Input
              TextFormField(
                controller: _usernameController,
                style: primaryTextStyle(),
                decoration: InputDecoration(
                  labelText: "Username",
                  hintText: "e.g., john_doe123",
                  prefixIcon: Icon(Iconsax.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed: () {
                            _usernameController.clear();
                            setState(() {
                              _isUsernameAvailable = false;
                              _checkingMessage = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _isUsernameAvailable = false;
                    _checkingMessage = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (!_usernameRegex.hasMatch(value)) {
                    return '3-20 characters, letters, numbers, and underscore only';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  LengthLimitingTextInputFormatter(20),
                ],
              ),

              12.height,

              // Username Availability Check
              if (_checkingMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isUsernameAvailable
                        ? Colors.green.withOpacity(0.1)
                        : _isChecking
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isUsernameAvailable
                          ? Colors.green
                          : _isChecking
                              ? Colors.blue
                              : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isChecking)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_isUsernameAvailable)
                        Icon(Icons.check_circle, color: Colors.green, size: 16)
                      else
                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                      8.width,
                      Expanded(
                        child: Text(
                          _checkingMessage,
                          style: TextStyle(
                            color: _isUsernameAvailable
                                ? Colors.green
                                : _isChecking
                                    ? Colors.blue
                                    : Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              16.height,

              // Check Availability Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isChecking ? null : _checkUsernameAvailability,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: kPrimary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isChecking
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimary,
                              ),
                            ),
                            8.width,
                            Text("Checking...",
                                style: boldTextStyle(color: kPrimary)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.search_normal, color: kPrimary),
                            8.width,
                            Text("Check Availability",
                                style: boldTextStyle(color: kPrimary)),
                          ],
                        ),
                ),
              ),

              32.height,

              // Terms & Conditions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Terms & Conditions",
                      style: boldTextStyle(size: 16),
                    ),
                    8.height,
                    Text(
                      "• You must comply with all platform rules and regulations\n"
                      "• Referrals must be genuine users\n"
                      "• Fraudulent activities will result in suspension\n"
                      "• Minimum withdrawal amount may apply\n"
                      "• Earnings are subject to verification",
                      style: secondaryTextStyle(size: 13, height: 1.5),
                    ),
                  ],
                ),
              ),

              24.height,

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_isUsernameAvailable
                      ? null
                      : _applyForReferralProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            12.width,
                            Text("Applying...",
                                style: boldTextStyle(color: Colors.white)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.medal, color: Colors.white),
                            12.width,
                            Text("Apply Now",
                                style: boldTextStyle(
                                    color: Colors.white, size: 16)),
                          ],
                        ),
                ),
              ),

              20.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          8.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: boldTextStyle(size: 14),
                ),
                4.height,
                Text(
                  description,
                  style: secondaryTextStyle(size: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

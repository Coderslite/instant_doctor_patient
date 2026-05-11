import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/password-screnn.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

class SignUpScreen extends StatefulWidget {
  final String email;
  final String? referredBy;
  const SignUpScreen({
    super.key,
    required this.email,
    required this.referredBy,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String gender = '';
  String completePhoneNumber = '';
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();
  final referredByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    referredByController.text = widget.referredBy.validate();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kText, size: 20),
            onPressed: () => finish(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                40.height,
                const Text(
                  'Complete Profile',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -1.0),
                ),
                12.height,
                const Text(
                  'Tell us a bit about yourself to personalize your healthcare experience.',
                  style: TextStyle(fontSize: 15, color: kSub, height: 1.5),
                ),
                48.height,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Verified Email Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: Color(0xFF16A34A), size: 20),
                            12.width,
                            Expanded(
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF16A34A)),
                              ),
                            ),
                            const Text('Verified',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF16A34A))),
                          ],
                        ),
                      ),

                      24.height,

                      _buildTextField(
                        controller: firstnameController,
                        label: 'First Name',
                        hint: 'e.g. John',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v!.isEmpty ? 'First name is required' : null,
                      ),
                      24.height,
                      _buildTextField(
                        controller: lastnameController,
                        label: 'Last Name',
                        hint: 'e.g. Doe',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v!.isEmpty ? 'Last name is required' : null,
                      ),
                      24.height,

                      // Phone Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone Number',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          10.height,
                          IntlPhoneField(
                            controller: phoneController,
                            initialCountryCode: 'US',
                            onChanged: (phone) {
                              completePhoneNumber = phone.completeNumber;
                            },
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              fillColor: const Color(0xFFF8FAFF),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                      color: kPrimary, width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                            ),
                          ),
                        ],
                      ),

                      16.height,

                      // Gender Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kText)),
                          12.height,
                          Row(
                            children: [
                              Expanded(
                                  child: _GenderOption(
                                label: 'Male',
                                icon: Icons.male_rounded,
                                isSelected: gender == 'Male',
                                onTap: () => setState(() => gender = 'Male'),
                              )),
                              16.width,
                              Expanded(
                                  child: _GenderOption(
                                label: 'Female',
                                icon: Icons.female_rounded,
                                isSelected: gender == 'Female',
                                onTap: () => setState(() => gender = 'Female'),
                              )),
                            ],
                          ),
                        ],
                      ),

                      32.height,

                      _buildTextField(
                        controller: referredByController,
                        label: 'Referral Code (Optional)',
                        hint: 'Enter code',
                        icon: Icons.card_giftcard_rounded,
                      ),

                      48.height,

                      PremiumButton(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            if (gender.isEmpty) {
                              toast("Please select your gender");
                              return;
                            }
                            if (completePhoneNumber.isEmpty) {
                              toast("Please enter a valid phone number");
                              return;
                            }
                            PasswordScreen(
                              email: widget.email,
                              firstname: firstnameController.text,
                              lastname: lastnameController.text,
                              phone: completePhoneNumber,
                              gender: gender,
                              isResetPassword: false,
                              referredBy: referredByController.text,
                            ).launch(context);
                          }
                        },
                        text: 'Continue',
                      ),

                      40.height,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
        10.height,
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kSub.withOpacity(0.4), fontSize: 14),
            prefixIcon: Icon(icon, color: kPrimary.withOpacity(0.5), size: 20),
            fillColor: const Color(0xFFF8FAFF),
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? kPrimary.withOpacity(0.05) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? kPrimary : kBorder.withOpacity(0.5),
              width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? kPrimary : kSub, size: 24),
            8.height,
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? kPrimary : kSub)),
          ],
        ),
      ),
    );
  }
}

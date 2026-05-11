import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/success_reset.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

import '../../constant/color.dart';

class PasswordScreen extends StatefulWidget {
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? email;
  final String? gender;
  final String? referredBy;
  final bool isResetPassword;
  const PasswordScreen({
    super.key,
    required this.isResetPassword,
    this.firstname,
    this.lastname,
    this.referredBy,
    this.phone,
    this.email,
    this.gender,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  final pass1 = TextEditingController();
  final pass2 = TextEditingController();
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  final authenticationController = Get.find<AuthenticationController>();

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
                Text(
                  widget.isResetPassword ? 'Reset Password' : 'Secure Account',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -1.0),
                ),
                12.height,
                Text(
                  widget.isResetPassword
                      ? 'Create a new secure password to regain access to your account.'
                      : 'Create a strong password to protect your healthcare information.',
                  style:
                      const TextStyle(fontSize: 15, color: kSub, height: 1.5),
                ),
                48.height,
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: pass1,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscureText: _obscurePassword1,
                        toggleObscure: () => setState(
                            () => _obscurePassword1 = !_obscurePassword1),
                        validator: (v) => v!.isEmpty
                            ? 'Password is required'
                            : (v.length < 6 ? 'Too short' : null),
                      ),
                      24.height,
                      _buildTextField(
                        controller: pass2,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        icon: Icons.lock_clock_outlined,
                        isPassword: true,
                        obscureText: _obscurePassword2,
                        toggleObscure: () => setState(
                            () => _obscurePassword2 = !_obscurePassword2),
                        validator: (v) =>
                            v != pass1.text ? 'Passwords do not match' : null,
                      ),
                      if (!widget.isResetPassword) ...[
                        32.height,
                        // Terms
                        GestureDetector(
                          onTap: () => setState(() => isChecked = !isChecked),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? kPrimary.withOpacity(0.05)
                                  : const Color(0xFFF8FAFF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isChecked
                                      ? kPrimary
                                      : kBorder.withOpacity(0.5),
                                  width: isChecked ? 2 : 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                    isChecked
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: isChecked ? kPrimary : kSub,
                                    size: 24),
                                12.width,
                                const Expanded(
                                  child: Text(
                                    'I agree to the Terms & Conditions and confirm my details are accurate.',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: kText,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      48.height,
                      Obx(() {
                        final loading =
                            authenticationController.isLoading.value;
                        return PremiumButton(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!widget.isResetPassword && !isChecked) {
                                toast("Please agree to the terms");
                                return;
                              }
                              if (widget.isResetPassword) {
                                const SuccessPassReset().launch(context);
                              } else {
                                authenticationController.handleSendOTP(
                                  email: widget.email.validate(),
                                  firstname: widget.firstname.validate(),
                                  lastname: widget.lastname.validate(),
                                  password: pass1.text,
                                  phoneNumber: widget.phone.validate(),
                                  gender: widget.gender.validate(),
                                  otpFor: OtpFor.register,
                                  referredBy: widget.referredBy.validate(),
                                );
                              }
                            }
                          },
                          isLoading: loading,
                          text: widget.isResetPassword
                              ? 'Reset Password'
                              : 'Create Account',
                        );
                      }),
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
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
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
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kSub.withOpacity(0.4), fontSize: 14),
            prefixIcon: Icon(icon, color: kPrimary.withOpacity(0.5), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: kSub,
                        size: 20),
                    onPressed: toggleObscure,
                  )
                : null,
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

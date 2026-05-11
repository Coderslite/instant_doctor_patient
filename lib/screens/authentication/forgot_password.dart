import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/services/AuthenticationService.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';

import '../../constant/color.dart';
import '../../services/UserService.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final userService = Get.find<UserService>();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isSending = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kText, size: 20),
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
                  'Reset Password',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                ),
                12.height,
                const Text(
                  'Forgot your password? No worries. Enter your registered email to receive a reset link.',
                  style: TextStyle(fontSize: 15, color: kSub, height: 1.5),
                ),
                48.height,

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: emailController,
                        label: 'Email Address',
                        hint: 'yourname@example.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.isEmpty ? 'Email is required' : (v.contains('@') ? null : 'Invalid email'),
                      ),
                      
                      32.height,
                      
                      // Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                            12.width,
                            const Expanded(
                              child: Text(
                                "We'll send a secure link to your email to create a new password.",
                                style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      48.height,

                      PremiumButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => isSending = true);
                            try {
                              var user = await userService.getUserByEmail(email: emailController.text);
                              if (user != null) {
                                await AuthenticationService().resetPassword(context, emailController.text);
                                toast("Reset link sent successfully");
                                Future.delayed(const Duration(seconds: 2), () => finish(context));
                              } else {
                                toast("User not found");
                              }
                            } catch (e) {
                              toast(e.toString());
                            } finally {
                              setState(() => isSending = false);
                            }
                          }
                        },
                        isLoading: isSending,
                        text: 'Send Reset Link',
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
        10.height,
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kSub.withOpacity(0.4), fontSize: 14),
            prefixIcon: Icon(icon, color: kPrimary.withOpacity(0.5), size: 20),
            fillColor: const Color(0xFFF8FAFF),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/screens/authentication/email_screen.dart';
import 'package:instant_doctor/screens/authentication/forgot_password.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:upgrader/upgrader.dart';
import '../../component/PremiumButton.dart';
import '../../constant/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authenticationController = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      showLater: false,
      showIgnore: false,
      shouldPopScope: () => false,
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(minutes: 1)),
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => finish(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kText, size: 20),
                  ),
                  40.height,
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                  ),
                  8.height,
                  const Text(
                    'We are happy to see you again. Please enter your details to continue.',
                    style: TextStyle(fontSize: 15, color: kSub, height: 1.4),
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
                        24.height,
                        _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => v!.isEmpty ? 'Password is required' : null,
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => const ForgotPassword().launch(context),
                            child: const Text('Forgot Password?', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                        
                        32.height,
                        
                        Obx(() {
                          final loading = authenticationController.isLoading.value;
                          return PremiumButton(
                            text: "Sign In",
                            isLoading: loading,
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await authenticationController.handleSignIn(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  context: context,
                                );
                              }
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  40.height,
                  
                  Row(
                    children: [
                      Expanded(child: Divider(color: kBorder.withOpacity(0.5))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR CONTINUE WITH', style: TextStyle(color: kSub, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      ),
                      Expanded(child: Divider(color: kBorder.withOpacity(0.5))),
                    ],
                  ),
                  
                  32.height,
                  
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          onTap: () => authenticationController.handleGoogleSignin(context, referredBy: ''),
                          icon: 'assets/images/google.png',
                          label: 'Google',
                        ),
                      ),
                      16.width,
                      Expanded(
                        child: _SocialButton(
                          onTap: () => authenticationController.handleAppleSignIn(context, referredBy: ''),
                          icon: 'assets/images/apple.png',
                          label: 'Apple',
                          isApple: true,
                        ),
                      ),
                    ],
                  ),
                  
                  48.height,
                  
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 15, color: kSub),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w900),
                            recognizer: TapGestureRecognizer()..onTap = () => const EmailScreen().launch(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kSub.withOpacity(0.4), fontSize: 14),
            prefixIcon: Icon(icon, color: kPrimary.withOpacity(0.5), size: 20),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: kSub, size: 20),
              onPressed: toggleObscure,
            ) : null,
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

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String label;
  final bool isApple;

  const _SocialButton({required this.onTap, required this.icon, required this.label, this.isApple = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 22, height: 22, color: isApple ? Colors.black : null),
              12.width,
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
            ],
          ),
        ),
      ),
    );
  }
}

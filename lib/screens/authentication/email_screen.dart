import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/login_screen.dart';
import 'package:instant_doctor/screens/authentication/signup.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../component/PremiumButton.dart';
import '../../constant/color.dart';
import '../../controllers/AuthenticationController.dart';

class EmailScreen extends StatefulWidget {
  final String? userId;
  const EmailScreen({super.key, this.userId});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final authenticationController = Get.put(AuthenticationController());

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
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                ),
                12.height,
                const Text(
                  'Join our community of healthcare professionals and patients. Enter your email to get started.',
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
                      
                      Obx(() {
                        final loading = authenticationController.isLoading.value;
                        return PremiumButton(
                          text: "Continue",
                          isLoading: loading,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              if (await authenticationController.handleCheckEmail(emailController.text)) {
                                SignUpScreen(
                                  email: emailController.text,
                                  referredBy: widget.userId,
                                ).launch(context);
                              } else {
                                toast("Email already exists");
                              }
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
                        onTap: () => authenticationController.handleGoogleSignin(context, referredBy: widget.userId.validate()),
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
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w900),
                          recognizer: TapGestureRecognizer()..onTap = () => const LoginScreen().launch(context),
                        ),
                      ],
                    ),
                  ),
                ),
                
                40.height,
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

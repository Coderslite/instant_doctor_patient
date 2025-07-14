import 'package:flutter/material.dart';
import 'package:instant_doctor/screens/authentication/confirm_pin_screen.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/DailPad.dart';
import '../../constant/color.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _pin = '';

  void _addPinDigit(String digit) {
    if (_pin.length < 5) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 5) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPinScreen(pin: _pin),
          ),
        );
      }
    }
  }

  void _removePinDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryDark, kPrimary],
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/sol_bg.png"),
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
              opacity: 0.03,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'Create Your PIN',
                  style: boldTextStyle(
                    size: 32,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter a 5-digit PIN',
                  style: primaryTextStyle(
                    size: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                // PIN display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _pin.length
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Dial pad
                Container(
                  padding: const EdgeInsets.all(20),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                        (digit) => DialButton(
                          text: digit,
                          onPressed: () => _addPinDigit(digit),
                        ),
                      ),
                      const SizedBox.shrink(),
                      DialButton(
                        text: '0',
                        onPressed: () => _addPinDigit('0'),
                      ),
                      DialButton(
                        icon: Icons.backspace,
                        onPressed: _removePinDigit,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.cover,
                    color: white,
                    opacity: AlwaysStoppedAnimation(0.6),
                  ),
                ),
                Text(
                  "Instant Doctor",
                  style: secondaryTextStyle(size: 16, color: whiteSmoke),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

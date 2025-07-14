import 'package:flutter/material.dart';
import 'package:instant_doctor/component/snackBar.dart';
import 'package:instant_doctor/screens/home/Root.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/DailPad.dart';
import '../../constant/color.dart';

class ConfirmPinScreen extends StatefulWidget {
  final String pin;

  const ConfirmPinScreen({super.key, required this.pin});

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  String _confirmPin = '';

  void _addPinDigit(String digit) async {
    if (_confirmPin.length < 5) {
      setState(() {
        _confirmPin += digit;
      });
      if (_confirmPin.length == 5) {
        if (_confirmPin == widget.pin) {
          var prefs = await SharedPreferences.getInstance();
          prefs.setString('pin', _confirmPin);
          successSnackBar(title: "PIN set successfully");
          Root().launch(context, isNewTask: true);
        } else {
          setState(() {
            _confirmPin = '';
          });
          errorSnackBar(title: 'PINs do not match');
        }
      }
    }
  }

  void _removePinDigit() {
    if (_confirmPin.isNotEmpty) {
      setState(() {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
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
                  'Confirm Your PIN',
                  style: boldTextStyle(
                    size: 32,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Re-enter your 5-digit PIN',
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
                          color: index < _confirmPin.length
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

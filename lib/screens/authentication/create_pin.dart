import 'package:flutter/material.dart';
import 'package:instant_doctor/constant/constants.dart';
import 'package:instant_doctor/screens/authentication/confirm_pin_screen.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:nb_utils/nb_utils.dart';
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
                  'Security First',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kText, letterSpacing: -1.0),
                ),
                12.height,
                const Text(
                  'Set up a 5-digit PIN to keep your health records secure and private.',
                  style: TextStyle(fontSize: 15, color: kSub, height: 1.5),
                ),
                64.height,

                // PIN Dots
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isActive = index < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? kPrimary : const Color(0xFFF0F2F8),
                          border: Border.all(
                            color: isActive ? kPrimary : kBorder.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: isActive ? [
                            BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                          ] : [],
                        ),
                      );
                    }),
                  ),
                ),

                80.height,

                // Dial Pad
                _buildDialPad(),
                
                40.height,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialPad() {
    return Column(
      children: [
        for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((digit) => _DialButton(
                text: digit,
                onPressed: () => _addPinDigit(digit),
              )).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80),
            _DialButton(text: '0', onPressed: () => _addPinDigit('0')),
            _DialButton(
              icon: Icons.backspace_outlined,
              onPressed: _removePinDigit,
            ),
          ],
        ),
      ],
    );
  }
}

class _DialButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _DialButton({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kBorder.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: kText, size: 24)
              : Text(text!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kText)),
        ),
      ),
    );
  }
}

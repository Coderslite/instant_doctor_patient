import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CalculatorDialpad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final Function() onDeletePressed;

  const CalculatorDialpad(
      {super.key, required this.onDigitPressed, required this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('7', context),
            _buildDigitButton('8', context),
            _buildDigitButton('9', context),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('4', context),
            _buildDigitButton('5', context),
            _buildDigitButton('6', context),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDigitButton('1', context),
            _buildDigitButton('2', context),
            _buildDigitButton('3', context),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEmptyButton(),
            _buildDigitButton('0', context),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitButton(String digit, BuildContext context) {
    return ElevatedButton(
      onPressed: () => onDigitPressed(digit),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(30.0),
        backgroundColor: context.cardColor,
      ),
      child: Text(
        digit,
        style: boldTextStyle(size: 20),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: onDeletePressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20.0),
        backgroundColor: Colors.redAccent,
      ),
      child: const Icon(
        Icons.backspace,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }

  Widget _buildEmptyButton() {
    return const SizedBox(
      width: 72,
      height: 72,
    );
  }
}

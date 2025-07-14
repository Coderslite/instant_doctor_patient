import 'package:flutter/material.dart';

class DialButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const DialButton({super.key, this.text, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    size: 28,
                    color:
                        Colors.white.withOpacity(onPressed != null ? 0.9 : 0.5),
                  )
                : Text(
                    text!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

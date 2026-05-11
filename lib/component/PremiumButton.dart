import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../constant/color.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final double? width;
  final double? height;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    this.onTap,
    this.enabled = true,
    this.width,
    this.height,
    this.child,
    this.color,
    this.textColor,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onTap: enabled && !isLoading ? onTap : null,
      width: width ?? (icon != null && text.isEmpty ? 56 : double.infinity),
      height: height,
      color: color ?? obsidian,
      textColor: textColor ?? white,
      disabledColor: border,
      disabledTextColor: slate,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: 0,
      padding: icon != null && text.isEmpty
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(vertical: 16),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: white,
                strokeWidth: 2,
              ),
            ).center()
          : child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor ?? white, size: 20),
                    if (text.isNotEmpty) 8.width,
                  ],
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: boldTextStyle(color: textColor ?? white),
                    ),
                ],
              ),
    );
  }
}

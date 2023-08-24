import 'package:flutter/material.dart';
import 'post_styles.dart';

class ButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppStyles.buttonBackgroundColor,
        padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.buttonPaddingHorizontal, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.buttonBorderRadius),
        ),
      ),
      child: Text(
        label,
      ),
    );
  }
}

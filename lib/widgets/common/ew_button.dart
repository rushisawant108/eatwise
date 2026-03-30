import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class EwButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;
  final bool loading;

  const EwButton({
    super.key,
    required this.label,
    required this.onTap,
    this.outline = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      );
    }

    return ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class InfoBoxWithActionWidget extends StatelessWidget {
  const InfoBoxWithActionWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
  });

  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.blue.shade50,
        border: Border.all(color: BaseColor.blue.shade200, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: BaseSize.w20,
                color: BaseColor.blue.shade700,
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  message,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (actionText != null && onActionPressed != null) ...[
            Gap.h8,
            TextButton(
              onPressed: onActionPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w12,
                  vertical: BaseSize.h8,
                ),
                backgroundColor: BaseColor.blue.shade100,
                foregroundColor: BaseColor.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
              ),
              child: Text(
                actionText!,
                style: BaseTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.blue.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

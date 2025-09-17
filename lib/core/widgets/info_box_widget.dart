import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class InfoBoxWidget extends StatelessWidget {
  const InfoBoxWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.blue.shade50,
        border: Border.all(
          color: BaseColor.blue.shade200,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
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
    );
  }
}

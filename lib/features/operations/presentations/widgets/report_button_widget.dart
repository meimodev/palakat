import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class ReportButtonWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ReportButtonWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        boxShadow: [
          BoxShadow(
            color: BaseColor.neutral20.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: BaseSize.w24,
                          height: BaseSize.w24,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        )
                      : Icon(icon, color: color, size: BaseSize.w24),
                ),

                Gap.w16,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BaseTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onPressed == null
                              ? BaseColor.neutral60
                              : BaseColor.neutral90,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        isLoading ? 'Generating report...' : description,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral60,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                if (!isLoading)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: onPressed == null
                        ? BaseColor.neutral40
                        : BaseColor.neutral60,
                    size: BaseSize.w16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

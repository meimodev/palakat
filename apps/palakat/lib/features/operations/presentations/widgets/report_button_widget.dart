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
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Icon Container with gradient
              Container(
                width: BaseSize.w48,
                height: BaseSize.w48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: BaseSize.w20,
                          height: BaseSize.w20,
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
                        fontWeight: FontWeight.bold,
                        color: onPressed == null
                            ? BaseColor.secondaryText
                            : BaseColor.black,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      isLoading ? 'Processing...' : description,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Gap.w8,

              // Arrow Icon
              if (!isLoading)
                Icon(
                  Icons.chevron_right,
                  color: onPressed == null
                      ? BaseColor.neutral40
                      : BaseColor.secondaryText,
                  size: BaseSize.w24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

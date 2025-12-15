import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/operations/data/operation_models.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Individual operation card with icon, title, and description.
/// Provides visual feedback on interaction and supports disabled state.
///
/// Requirements: 3.2, 3.3, 5.1, 5.3, 5.4
class OperationItemCard extends StatelessWidget {
  const OperationItemCard({
    super.key,
    required this.operation,
    required this.onTap,
  });

  /// The operation data to display
  final OperationItem operation;

  /// Callback when the card is tapped (only called if operation is enabled)
  final VoidCallback onTap;

  /// Opacity for disabled state (Requirement 5.4)
  static const double disabledOpacity = 0.5;

  /// Border radius for the card (Requirement 3.3 - 16px)
  static const double borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final title = _operationTitle(context, operation);
    final description = _operationDescription(context, operation);

    return Opacity(
      opacity: operation.isEnabled ? 1.0 : disabledOpacity,
      child: Material(
        color: BaseColor.surfaceLight,
        elevation: 0,
        shadowColor: BaseColor.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Only respond to taps if enabled (Requirement 5.4)
          onTap: operation.isEnabled ? onTap : null,
          // Ripple effect with primary color at 10% opacity (Requirement 5.1)
          splashColor: BaseColor.primary.withValues(alpha: 0.1),
          highlightColor: BaseColor.primary.withValues(alpha: 0.05),
          child: Tooltip(
            // Tooltip on long-press (Requirement 5.2)
            message: description,
            preferBelow: true,
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Row(
                children: [
                  // Operation icon container
                  _OperationIcon(
                    icon: operation.icon,
                    isEnabled: operation.isEnabled,
                  ),
                  Gap.w12,
                  // Title and description
                  Expanded(
                    child: _OperationContent(
                      title: title,
                      description: description,
                      isEnabled: operation.isEnabled,
                    ),
                  ),
                  Gap.w8,
                  // Chevron indicator
                  Icon(
                    AppIcons.forward,
                    color: operation.isEnabled
                        ? BaseColor.textSecondary
                        : BaseColor.textDisabled,
                    size: BaseSize.w24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _operationTitle(BuildContext context, OperationItem operation) {
  final l10n = context.l10n;
  switch (operation.id) {
    case 'publish_service':
      return l10n.operationsItem_publish_service_title;
    case 'publish_event':
      return l10n.operationsItem_publish_event_title;
    case 'publish_announcement':
      return l10n.operationsItem_publish_announcement_title;
    case 'add_income':
      return l10n.operationsItem_add_income_title;
    case 'add_expense':
      return l10n.operationsItem_add_expense_title;
    case 'generate_report':
      return l10n.operationsItem_generate_report_title;
    default:
      return operation.title;
  }
}

String _operationDescription(BuildContext context, OperationItem operation) {
  final l10n = context.l10n;
  switch (operation.id) {
    case 'publish_service':
      return l10n.operationsItem_publish_service_desc;
    case 'publish_event':
      return l10n.operationsItem_publish_event_desc;
    case 'publish_announcement':
      return l10n.operationsItem_publish_announcement_desc;
    case 'add_income':
      return l10n.operationsItem_add_income_desc;
    case 'add_expense':
      return l10n.operationsItem_add_expense_desc;
    case 'generate_report':
      return l10n.operationsItem_generate_report_desc;
    default:
      return operation.description;
  }
}

/// Icon container for the operation card
class _OperationIcon extends StatelessWidget {
  const _OperationIcon({required this.icon, required this.isEnabled});

  final IconData icon;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: BaseSize.w48,
      height: BaseSize.w48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isEnabled ? BaseColor.primary[50] : BaseColor.neutral[100],
        borderRadius: BorderRadius.circular(BaseSize.w12),
      ),
      child: Icon(
        icon,
        color: isEnabled ? BaseColor.primary : BaseColor.textDisabled,
        size: BaseSize.w24,
      ),
    );
  }
}

/// Content section with title and description
class _OperationContent extends StatelessWidget {
  const _OperationContent({
    required this.title,
    required this.description,
    required this.isEnabled,
  });

  final String title;
  final String description;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title (Requirement 5.3)
        Text(
          title,
          style: BaseTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isEnabled ? BaseColor.textPrimary : BaseColor.textDisabled,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Description (Requirement 5.3)
        Text(
          description,
          style: BaseTypography.bodySmall.copyWith(
            color: isEnabled ? BaseColor.textSecondary : BaseColor.textDisabled,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

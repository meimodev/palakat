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
  static final double borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final title = _operationTitle(context, operation);
    final description = _operationDescription(context, operation);

    return Opacity(
      opacity: operation.isEnabled ? 1.0 : disabledOpacity,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shadowColor: AppColors.onSurface,
        surfaceTintColor: AppColors.neutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: AppColors.neutral, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Only respond to taps if enabled (Requirement 5.4)
          onTap: operation.isEnabled ? onTap : null,
          // Ripple effect with primary color at 10% opacity (Requirement 5.1)
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Tooltip(
            // Tooltip on long-press (Requirement 5.2)
            message: description,
            preferBelow: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth < 260 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.1;

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Operation icon container
                                _OperationIcon(
                                  icon: operation.icon,
                                  isEnabled: operation.isEnabled,
                                  isCompact: isCompact,
                                ),
                                Gap.w10,
                                // Title and description
                                Expanded(
                                  child: _OperationContent(
                                    title: title,
                                    description: description,
                                    isEnabled: operation.isEnabled,
                                    isCompact: isCompact,
                                  ),
                                ),
                              ],
                            ),
                            Gap.h8,
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                AppIcons.forward,
                                color: operation.isEnabled
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.onSurface.withValues(
                                        alpha: 0.38,
                                      ),
                                size: 18.0,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            // Operation icon container
                            _OperationIcon(
                              icon: operation.icon,
                              isEnabled: operation.isEnabled,
                              isCompact: isCompact,
                            ),
                            Gap.w10,
                            // Title and description
                            Expanded(
                              child: _OperationContent(
                                title: title,
                                description: description,
                                isEnabled: operation.isEnabled,
                                isCompact: isCompact,
                              ),
                            ),
                            Gap.w6,
                            // Chevron indicator
                            Icon(
                              AppIcons.forward,
                              color: operation.isEnabled
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onSurface.withValues(alpha: 0.38),
                              size: 18.0,
                            ),
                          ],
                        ),
                );
              },
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
  const _OperationIcon({
    required this.icon,
    required this.isEnabled,
    required this.isCompact,
  });

  final IconData icon;
  final bool isEnabled;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 26.0 : 32.0,
      height: isCompact ? 26.0 : 32.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary : AppColors.secondary.shade200,
        border: Border.all(
          color: isEnabled
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.ghostBorder(0.08),
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      child: Icon(
        icon,
        color: isEnabled ? AppColors.neutral : AppColors.secondary,
        size: isCompact ? 12.0 : 14.0,
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
    required this.isCompact,
  });

  final String title;
  final String description;
  final bool isEnabled;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title (Requirement 5.3)
        Text(
          title,
          style:
              (isCompact
                      ? Theme.of(context).textTheme.bodyMedium!
                      : Theme.of(context).textTheme.titleMedium!)
                  .copyWith(
                    fontWeight: FontWeight.w700,
                    color: isEnabled
                        ? AppColors.onSurface
                        : AppColors.onSurface.withValues(alpha: 0.38),
                  ),
          maxLines: isCompact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Description (Requirement 5.3)
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: isEnabled
                ? AppColors.onSurfaceVariant
                : AppColors.onSurface.withValues(alpha: 0.38),
          ),
          maxLines: isCompact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

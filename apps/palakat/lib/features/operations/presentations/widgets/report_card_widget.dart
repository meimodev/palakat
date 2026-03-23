import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/extension.dart';

class ReportCardWidget extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReportCardWidget({
    super.key,
    required this.report,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Report Type Icon
                    Container(
                      width: 40.0,
                      height: 40.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getGenerationTypeColor(
                          report.generatedBy,
                        ).withValues(alpha: 0.1),
                        border: Border.all(
                          color: _getGenerationTypeColor(report.generatedBy)
                              .withValues(alpha: 0.24),
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                      ),
                      child: Icon(
                        _getGenerationTypeIcon(report.generatedBy),
                        color: _getGenerationTypeColor(report.generatedBy),
                        size: 20.0,
                      ),
                    ),
                    Gap.w12,

                    // Report Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.name,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h4,
                          Text(
                            _getGenerationTypeLabel(
                              context,
                              report.generatedBy,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: _getGenerationTypeColor(
                                report.generatedBy,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Button
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.delete,
                                size: 16,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.btn_delete,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        AppIcons.moreVert,
                        color: AppColors.tertiary,
                        size: 20.0,
                      ),
                    ),
                  ],
                ),

                Gap.h12,

                // File info
                Text(
                  '${context.l10n.tbl_file}: ${_getFileName(context, report.file)}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.tertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                Gap.h8,

                // Generated Date
                if (report.createdAt != null)
                  Row(
                    children: [
                      Icon(
                        AppIcons.schedule,
                        size: 16.0,
                        color: AppColors.tertiary,
                      ),
                      Gap.w4,
                      Text(
                        '${context.l10n.tbl_on} ${_formatDate(context, report.createdAt!)}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGenerationTypeColor(GeneratedBy type) {
    switch (type) {
      case GeneratedBy.manual:
        return AppColors.primary; // Blue for manual
      case GeneratedBy.system:
        return AppColors.primary; // Teal for system
    }
  }

  IconData _getGenerationTypeIcon(GeneratedBy type) {
    switch (type) {
      case GeneratedBy.manual:
        return AppIcons.person;
      case GeneratedBy.system:
        return AppIcons.autoAwesome;
    }
  }

  String _getGenerationTypeLabel(BuildContext context, GeneratedBy type) {
    switch (type) {
      case GeneratedBy.manual:
        return context.l10n.opt_manual;
      case GeneratedBy.system:
        return context.l10n.opt_system;
    }
  }

  String _getFileName(BuildContext context, FileManager file) {
    final originalName = file.originalName;
    if (originalName != null && originalName.trim().isNotEmpty) {
      return originalName;
    }

    final path = file.path;
    if (path != null && path.trim().isNotEmpty) {
      final segments = path.split('/');
      return segments.isNotEmpty ? segments.last : context.l10n.lbl_na;
    }

    return context.l10n.lbl_na;
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.yMMMd(locale).format(date);
  }
}

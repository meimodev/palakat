import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ReportDetailBottomSheet extends StatelessWidget {
  final Report report;

  const ReportDetailBottomSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 4),
            ),
          ),

          Gap.h24,

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getGenerationTypeColor(
                      report.generatedBy,
                    ).withValues(alpha: 0.1),
                    border: Border.all(
                      color: _getGenerationTypeColor(report.generatedBy)
                          .withValues(alpha: 0.24),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                  ),
                  child: Icon(
                    _getGenerationTypeIcon(report.generatedBy),
                    color: _getGenerationTypeColor(report.generatedBy),
                    size: 24.0,
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        report.createdAt != null
                            ? l10n.msg_generatedOn(
                                _formatDate(context, report.createdAt!),
                              )
                            : l10n.msg_noGenerationDate,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Gap.h24,

          // Content based on report type
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildReportContent(context),
            ),
          ),

          Gap.h24,

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ButtonWidget.outlined(
                    text: l10n.btn_close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ButtonWidget.primary(
                    text: l10n.btn_export,
                    onTap: () {
                      // Note: Export functionality pending.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.msg_exportComingSoon)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Report Details Card
        Material(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: AppColors.neutral, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(context, l10n.tbl_reportName, report.name),
                Gap.h12,
                _buildInfoRow(
                  context,
                  l10n.lbl_generationType,
                  _getGenerationTypeLabel(context, report.generatedBy),
                ),
                Gap.h12,
                if (report.church != null)
                  _buildInfoRow(context, l10n.nav_church, report.church!.name),
                if (report.church != null) Gap.h12,
                _buildInfoRow(
                  context,
                  l10n.tbl_file,
                  _getFileName(context, report.file),
                ),
                Gap.h12,
                if (report.createdAt != null)
                  _buildInfoRow(
                    context,
                    l10n.lbl_createdAt,
                    _formatDate(context, report.createdAt!),
                  ),
                if (report.updatedAt != null) ...[
                  Gap.h12,
                  _buildInfoRow(
                    context,
                    l10n.lbl_updatedAt,
                    _formatDate(context, report.updatedAt!),
                  ),
                ],
              ],
            ),
          ),
        ),
        Gap.h16,
        Text(
          l10n.msg_downloadReportToViewDetails,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Gap.w16,
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getGenerationTypeColor(GeneratedBy type) {
    switch (type) {
      case GeneratedBy.manual:
        return AppColors.primary; // Blue
      case GeneratedBy.system:
        return AppColors.success; // Green
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
      return segments.isNotEmpty ? segments.last : context.l10n.lbl_unknown;
    }

    return context.l10n.lbl_unknown;
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.yMMMd(locale).format(date);
  }
}

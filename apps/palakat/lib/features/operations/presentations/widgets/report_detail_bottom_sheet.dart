import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ReportDetailBottomSheet extends StatelessWidget {
  final Report report;

  const ReportDetailBottomSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BaseSize.radiusLg),
          topRight: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: BaseSize.h12),
            width: BaseSize.w40,
            height: BaseSize.h4,
            decoration: BoxDecoration(
              color: BaseColor.neutral40,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
          ),

          Gap.h24,

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Row(
              children: [
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _getGenerationTypeColor(
                      report.generatedBy,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Icon(
                    _getGenerationTypeIcon(report.generatedBy),
                    color: _getGenerationTypeColor(report.generatedBy),
                    size: BaseSize.w24,
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        report.createdAt != null
                            ? l10n.msg_generatedOn(
                                _formatDate(context, report.createdAt!),
                              )
                            : l10n.msg_noGenerationDate,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral60,
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
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: _buildReportContent(context),
            ),
          ),

          Gap.h24,

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.btn_close),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.msg_exportComingSoon)),
                      );
                    },
                    child: Text(l10n.btn_export),
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
        Container(
          padding: EdgeInsets.all(BaseSize.w16),
          decoration: BoxDecoration(
            color: BaseColor.neutral10,
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          ),
          child: Column(
            children: [
              _buildInfoRow(l10n.tbl_reportName, report.name),
              Gap.h12,
              _buildInfoRow(
                l10n.lbl_generationType,
                _getGenerationTypeLabel(context, report.generatedBy),
              ),
              Gap.h12,
              if (report.church != null)
                _buildInfoRow(l10n.nav_church, report.church!.name),
              if (report.church != null) Gap.h12,
              _buildInfoRow(l10n.tbl_file, _getFileName(context, report.file)),
              Gap.h12,
              if (report.createdAt != null)
                _buildInfoRow(
                  l10n.lbl_createdAt,
                  _formatDate(context, report.createdAt!),
                ),
              if (report.updatedAt != null) ...[
                Gap.h12,
                _buildInfoRow(
                  l10n.lbl_updatedAt,
                  _formatDate(context, report.updatedAt!),
                ),
              ],
            ],
          ),
        ),
        Gap.h16,
        Text(
          l10n.msg_downloadReportToViewDetails,
          style: BaseTypography.bodySmall.copyWith(
            color: BaseColor.neutral60,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: BaseTypography.bodyMedium.copyWith(color: BaseColor.neutral60),
        ),
        Gap.w16,
        Flexible(
          child: Text(
            value,
            style: BaseTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
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
        return const Color(0xFF3B82F6); // Blue
      case GeneratedBy.system:
        return const Color(0xFF10B981); // Green
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

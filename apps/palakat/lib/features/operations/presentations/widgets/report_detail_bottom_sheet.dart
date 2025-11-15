import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ReportDetailBottomSheet extends StatelessWidget {
  final Report report;

  const ReportDetailBottomSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
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
                            ? 'Generated on ${_formatDate(report.createdAt!)}'
                            : 'No generation date',
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
              child: _buildReportContent(),
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
                    child: const Text('Close'),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export functionality coming soon'),
                        ),
                      );
                    },
                    child: const Text('Export'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
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
              _buildInfoRow('Report Name', report.name),
              Gap.h12,
              _buildInfoRow(
                'Generation Type',
                _getGenerationTypeLabel(report.generatedBy),
              ),
              Gap.h12,
              if (report.church != null)
                _buildInfoRow('Church', report.church!.name),
              if (report.church != null) Gap.h12,
              _buildInfoRow('File', _getFileName(report.file.url)),
              Gap.h12,
              if (report.createdAt != null)
                _buildInfoRow('Created', _formatDate(report.createdAt!)),
              if (report.updatedAt != null) ...[
                Gap.h12,
                _buildInfoRow('Last Updated', _formatDate(report.updatedAt!)),
              ],
            ],
          ),
        ),
        Gap.h16,
        Text(
          'To view the full report details, please download the file.',
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
          style: BaseTypography.bodyMedium.copyWith(
            color: BaseColor.neutral60,
          ),
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
        return Icons.person_outline;
      case GeneratedBy.system:
        return Icons.auto_awesome;
    }
  }

  String _getGenerationTypeLabel(GeneratedBy type) {
    switch (type) {
      case GeneratedBy.manual:
        return 'Manual Report';
      case GeneratedBy.system:
        return 'System Generated';
    }
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      return segments.isNotEmpty ? segments.last : 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

}

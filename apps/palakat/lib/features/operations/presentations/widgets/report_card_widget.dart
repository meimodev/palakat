import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Report Type Icon
                    Container(
                      width: BaseSize.w40,
                      height: BaseSize.w40,
                      decoration: BoxDecoration(
                        color: _getGenerationTypeColor(
                          report.generatedBy,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Icon(
                        _getGenerationTypeIcon(report.generatedBy),
                        color: _getGenerationTypeColor(report.generatedBy),
                        size: BaseSize.w20,
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
                            style: BaseTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap.h4,
                          Text(
                            _getGenerationTypeLabel(report.generatedBy),
                            style: BaseTypography.bodySmall.copyWith(
                              color: _getGenerationTypeColor(report.generatedBy),
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
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: BaseColor.neutral60,
                        size: BaseSize.w20,
                      ),
                    ),
                  ],
                ),

                Gap.h12,

                // File info
                Text(
                  'File: ${_getFileName(report.file.url)}',
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral60,
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
                        Icons.schedule,
                        size: BaseSize.w16,
                        color: BaseColor.neutral60,
                      ),
                      Gap.w4,
                      Text(
                        'Generated on ${_formatDate(report.createdAt!)}',
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral60,
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

import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/enums.dart';
import 'church.dart';
import 'report.dart';

part 'report_job.freezed.dart';
part 'report_job.g.dart';

@freezed
abstract class ReportJob with _$ReportJob {
  const factory ReportJob({
    required int id,
    @Default(ReportJobStatus.pending) ReportJobStatus status,
    required ReportGenerateType type,
    @Default(ReportFormat.pdf) ReportFormat format,
    Map<String, dynamic>? params,
    String? errorMessage,
    @Default(0) int progress,
    required int churchId,
    Church? church,
    required int requestedById,
    int? reportId,
    Report? report,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) = _ReportJob;

  factory ReportJob.fromJson(Map<String, dynamic> json) =>
      _$ReportJobFromJson(json);
}

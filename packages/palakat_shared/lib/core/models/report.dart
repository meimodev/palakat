import 'package:freezed_annotation/freezed_annotation.dart';
import '../constants/enums.dart';
import 'church.dart';
import 'file_manager.dart';

part 'report.freezed.dart';

part 'report.g.dart';

@freezed
abstract class Report with _$Report {
  const factory Report({
    int? id,
    required String name,
    @Default(ReportGenerateType.incomingDocument) ReportGenerateType type,
    @Default(ReportFormat.pdf) ReportFormat format,
    Map<String, dynamic>? params,
    required GeneratedBy generatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int churchId,
    Church? church,
    required int fileId,
    required FileManager file,
    int? createdById,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

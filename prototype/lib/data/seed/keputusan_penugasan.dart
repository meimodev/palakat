import '../../core/tanggal.dart';

/// The written church decision Penugasan offers for a new assignment
/// (screens/15 AlurPenugasan, mock-data DokumenGereja "SK BPMJ No. 14/…";
/// an SK takes the year of its record's date, README 5.5).
// ponytail: one fixed decision until Dokumen gereja (M7) lists its
// "Keputusan dan surat edaran"; the M10 join reads the chips from there.
String keputusanPenugasan(Tanggal hari) => 'SK BPMJ No. 14/${hari.tahun}';

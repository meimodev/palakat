import '../../domain/collaboration/collaboration.dart';

/// The Collaboration tables (README 5.7), owned by M9: Panitia, services,
/// attendance counts, fund requests and the approver table.
class TabelKolaborasi {
  /// Oldest first.
  final List<Panitia> panitia = [];
  final List<Service> services = [];

  /// By service id.
  final Map<String, AttendanceCount> attendance = {};
  final List<FundRequest> fundRequests = [];
  final approverTable = ApproverTable();

  Panitia? panitiaById(String id) =>
      panitia.where((p) => p.id == id).firstOrNull;
  Service? service(String id) => services.where((s) => s.id == id).firstOrNull;
  FundRequest? fundRequest(String id) =>
      fundRequests.where((r) => r.id == id).firstOrNull;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/services/realtime_events_service.dart';
import 'package:palakat_shared/core/widgets/app_snackbars.dart';

class AdminApprovalRealtimeListener extends ConsumerStatefulWidget {
  const AdminApprovalRealtimeListener({super.key, required this.child});

  final Widget child;

  static const Set<String> _activityEventNames = {
    'activity.created',
    'activity.updated',
  };

  static const Set<String> _approvalEventNames = {
    'approval.required',
    'approval.approved',
    'approval.rejected',
    'approval.override.approved',
    'approval.override.rejected',
  };

  static const Set<String> _financeEventNames = {
    'finance.created',
    'finance.updated',
    'finance.deleted',
  };

  @override
  ConsumerState<AdminApprovalRealtimeListener> createState() =>
      _AdminApprovalRealtimeListenerState();
}

class _AdminApprovalRealtimeListenerState
    extends ConsumerState<AdminApprovalRealtimeListener> {
  String? _lastToastKey;
  DateTime? _lastToastAt;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider).asData?.value;
    final currentChurchId = auth?.account.membership?.church?.id;
    final l10n = context.l10n;

    ref.listen(realtimeEventProvider, (_, next) {
      final event = next.asData?.value;
      if (event == null ||
          (!AdminApprovalRealtimeListener._approvalEventNames.contains(
                event.name,
              ) &&
              !AdminApprovalRealtimeListener._financeEventNames.contains(
                event.name,
              ) &&
              !AdminApprovalRealtimeListener._activityEventNames.contains(
                event.name,
              ))) {
        return;
      }

      if (auth == null || currentChurchId == null) {
        return;
      }

      final raw = event.payload['data'] is Map
          ? event.payload['data']
          : event.payload;
      if (raw is! Map) {
        return;
      }

      final data = <String, dynamic>{};
      raw.forEach((key, value) {
        data[key.toString()] = value;
      });

      final eventChurchId = _asInt(data['churchId']);
      if (eventChurchId == null || eventChurchId != currentChurchId) {
        return;
      }

      if (AdminApprovalRealtimeListener._activityEventNames.contains(
            event.name,
          ) &&
          data['changeSource']?.toString() != 'activity') {
        return;
      }

      final message = _buildMessage(
        l10n: l10n,
        eventName: event.name,
        entityType: data['entityType']?.toString(),
        financeType: data['financeType']?.toString(),
        entityTitle:
            data['entityTitle']?.toString() ??
            data['activityTitle']?.toString(),
        actorName: data['actorName']?.toString(),
      );

      if (message == null || message.isEmpty) {
        return;
      }

      final toastKey = _buildToastKey(event.name, data);
      if (_shouldSuppressToast(toastKey)) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }

        if (event.name == 'approval.rejected' ||
            event.name == 'approval.override.rejected') {
          AppSnackbars.showError(context, title: 'Approval', message: message);
          return;
        }

        AppSnackbars.showSuccess(
          context,
          title:
              AdminApprovalRealtimeListener._activityEventNames.contains(
                event.name,
              )
              ? 'Activity'
              : AdminApprovalRealtimeListener._financeEventNames.contains(
                  event.name,
                )
              ? l10n.nav_finance
              : 'Approval',
          message: message,
        );
      });
    });

    return widget.child;
  }

  bool _shouldSuppressToast(String toastKey) {
    final now = DateTime.now();
    final lastToastAt = _lastToastAt;

    if (_lastToastKey == toastKey && lastToastAt != null) {
      final elapsed = now.difference(lastToastAt);
      if (elapsed < const Duration(seconds: 2)) {
        return true;
      }
    }

    _lastToastKey = toastKey;
    _lastToastAt = now;
    return false;
  }

  String _buildToastKey(String eventName, Map<String, dynamic> data) {
    return [
      eventName,
      data['entityId']?.toString() ??
          data['activityId']?.toString() ??
          data['financeId']?.toString() ??
          '',
      data['resultingStatus']?.toString() ?? '',
      data['financeType']?.toString() ?? '',
      data['changeSource']?.toString() ?? '',
      data['updatedAt']?.toString() ?? '',
    ].join('|');
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  String? _buildMessage({
    required dynamic l10n,
    required String eventName,
    required String? entityType,
    required String? financeType,
    required String? entityTitle,
    required String? actorName,
  }) {
    final entityLabel = _formatEntityLabel(entityType, entityTitle);
    final actorLabel = actorName != null && actorName.trim().isNotEmpty
        ? actorName.trim()
        : 'Someone';
    final financeLabel = _formatFinanceLabel(l10n, financeType);

    switch (eventName) {
      case 'activity.created':
        return 'Activity $entityLabel created.';
      case 'activity.updated':
        return 'Activity $entityLabel updated.';
      case 'finance.created':
        return l10n.msg_financeRealtimeCreated(financeLabel);
      case 'finance.updated':
        return l10n.msg_financeRealtimeUpdated(financeLabel);
      case 'finance.deleted':
        return l10n.msg_financeRealtimeDeleted(financeLabel);
      case 'approval.required':
        return 'New approval required for $entityLabel.';
      case 'approval.approved':
        return '$actorLabel approved $entityLabel.';
      case 'approval.rejected':
        return '$actorLabel rejected $entityLabel.';
      case 'approval.override.approved':
        return '$actorLabel applied an approval override for $entityLabel.';
      case 'approval.override.rejected':
        return '$actorLabel applied a rejection override for $entityLabel.';
      default:
        return null;
    }
  }

  String _formatFinanceLabel(dynamic l10n, String? financeType) {
    switch (financeType?.toUpperCase()) {
      case 'EXPENSE':
        return l10n.financeType_expense;
      case 'REVENUE':
      default:
        return l10n.financeType_revenue;
    }
  }

  String _formatEntityLabel(String? entityType, String? entityTitle) {
    final normalizedTitle = entityTitle?.trim();
    if (normalizedTitle != null && normalizedTitle.isNotEmpty) {
      return '"$normalizedTitle"';
    }

    switch (entityType) {
      case 'ACTIVITY':
        return 'an activity';
      case 'REVENUE':
        return 'a revenue entry';
      case 'EXPENSE':
        return 'an expense entry';
      default:
        return 'an approval item';
    }
  }
}

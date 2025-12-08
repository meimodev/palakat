import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/approval/presentations/widgets/approver_status_badge.dart';

/// Property-based tests for ApproverStatusBadge widget.
/// **Feature: approval-card-detail-redesign**
void main() {
  group('ApproverStatusBadge Property Tests', () {
    /// **Feature: approval-card-detail-redesign, Property 2: Status icon color matches approval status**
    /// **Validates: Requirements 3.2, 3.3, 3.4**
    ///
    /// *For any* approver with a given ApprovalStatus, the status icon color SHALL match
    /// the expected color (green for approved, red for rejected, amber for unconfirmed).
    property('Property 2: Status icon color matches approval status', () {
      forAll(_approvalStatusArbitrary(), (status) {
        final color = ApproverStatusBadge.getStatusColor(status);
        final icon = ApproverStatusBadge.getStatusIcon(status);

        switch (status) {
          case ApprovalStatus.approved:
            // Green checkmark for approved
            expect(
              color,
              equals(BaseColor.green.shade600),
              reason: 'Approved status should have green color',
            );
            expect(
              icon,
              equals(Icons.check_circle),
              reason: 'Approved status should have checkmark icon',
            );
            break;
          case ApprovalStatus.rejected:
            // Red X for rejected
            expect(
              color,
              equals(BaseColor.red.shade500),
              reason: 'Rejected status should have red color',
            );
            expect(
              icon,
              equals(Icons.cancel),
              reason: 'Rejected status should have cancel/X icon',
            );
            break;
          case ApprovalStatus.unconfirmed:
            // Amber clock for unconfirmed/pending
            expect(
              color,
              equals(BaseColor.yellow.shade700),
              reason: 'Unconfirmed status should have amber/yellow color',
            );
            expect(
              icon,
              equals(Icons.schedule),
              reason: 'Unconfirmed status should have schedule/clock icon',
            );
            break;
        }
      });
    });

    /// Additional property: Status label consistency
    /// *For any* ApprovalStatus, the label should be non-empty and match expected values.
    property('Status label is consistent with status', () {
      forAll(_approvalStatusArbitrary(), (status) {
        final label = ApproverStatusBadge.getStatusLabel(status);

        expect(label, isNotEmpty, reason: 'Status label should not be empty');

        switch (status) {
          case ApprovalStatus.approved:
            expect(
              label,
              equals('Approved'),
              reason: 'Approved status should have "Approved" label',
            );
            break;
          case ApprovalStatus.rejected:
            expect(
              label,
              equals('Rejected'),
              reason: 'Rejected status should have "Rejected" label',
            );
            break;
          case ApprovalStatus.unconfirmed:
            expect(
              label,
              equals('Pending'),
              reason: 'Unconfirmed status should have "Pending" label',
            );
            break;
        }
      });
    });

    /// Property: Color-icon-label consistency
    /// *For any* ApprovalStatus, the color, icon, and label should all be consistent
    /// with each other (all represent the same semantic meaning).
    property('Color, icon, and label are semantically consistent', () {
      forAll(_approvalStatusArbitrary(), (status) {
        final color = ApproverStatusBadge.getStatusColor(status);
        final icon = ApproverStatusBadge.getStatusIcon(status);
        final label = ApproverStatusBadge.getStatusLabel(status);

        // Verify semantic consistency
        if (color == BaseColor.green.shade600) {
          expect(icon, equals(Icons.check_circle));
          expect(label, equals('Approved'));
        } else if (color == BaseColor.red.shade500) {
          expect(icon, equals(Icons.cancel));
          expect(label, equals('Rejected'));
        } else if (color == BaseColor.yellow.shade700) {
          expect(icon, equals(Icons.schedule));
          expect(label, equals('Pending'));
        } else {
          fail('Unexpected color: $color');
        }
      });
    });
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates an ApprovalStatus value.
Arbitrary<ApprovalStatus> _approvalStatusArbitrary() {
  return integer(
    min: 0,
    max: ApprovalStatus.values.length - 1,
  ).map((index) => ApprovalStatus.values[index]);
}

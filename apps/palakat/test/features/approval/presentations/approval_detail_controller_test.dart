import 'package:flutter_test/flutter_test.dart';
import 'package:palakat/features/approval/presentations/approval_detail_controller.dart';
import 'package:palakat/features/approval/presentations/approval_detail_state.dart';

/// Unit tests for ApprovalDetailController
/// **Feature: announcement-financial-admin-cleanup-approval-redesign**
/// **Validates: Requirements 3.8**
void main() {
  group('ApprovalDetailController Unit Tests', () {
    test('initial state should have loadingScreen true', () {
      // The initial state should have loadingScreen set to true
      const initialState = ApprovalDetailState();
      expect(initialState.loadingScreen, isTrue);
      expect(initialState.activity, isNull);
      expect(initialState.errorMessage, isNull);
    });

    test('state should have correct default values', () {
      const state = ApprovalDetailState();
      expect(state.loadingScreen, equals(true));
      expect(state.activity, isNull);
      expect(state.errorMessage, isNull);
    });

    test('state copyWith should update loadingScreen correctly', () {
      const state = ApprovalDetailState();
      final updatedState = state.copyWith(loadingScreen: false);
      expect(updatedState.loadingScreen, isFalse);
      expect(updatedState.activity, isNull);
      expect(updatedState.errorMessage, isNull);
    });

    test('state copyWith should update errorMessage correctly', () {
      const state = ApprovalDetailState();
      final updatedState = state.copyWith(
        loadingScreen: false,
        errorMessage: 'Test error message',
      );
      expect(updatedState.loadingScreen, isFalse);
      expect(updatedState.errorMessage, equals('Test error message'));
    });

    test('state copyWith should clear errorMessage when set to null', () {
      const state = ApprovalDetailState(
        loadingScreen: false,
        errorMessage: 'Some error',
      );
      final updatedState = state.copyWith(errorMessage: null);
      expect(updatedState.errorMessage, isNull);
    });

    test('ApprovalDetailState equality works correctly', () {
      const state1 = ApprovalDetailState();
      const state2 = ApprovalDetailState();
      expect(state1, equals(state2));
    });

    test('ApprovalDetailState with different values are not equal', () {
      const state1 = ApprovalDetailState(loadingScreen: true);
      const state2 = ApprovalDetailState(loadingScreen: false);
      expect(state1, isNot(equals(state2)));
    });
  });

  group('ApprovalDetailController Provider Tests', () {
    test('provider family should accept activityId parameter', () {
      // Verify the provider can be created with an activityId
      // This tests that the provider signature is correct
      final provider = approvalDetailControllerProvider(activityId: 1);
      expect(provider, isNotNull);
    });

    test(
      'provider family should create different providers for different IDs',
      () {
        final provider1 = approvalDetailControllerProvider(activityId: 1);
        final provider2 = approvalDetailControllerProvider(activityId: 2);
        // Different activity IDs should create different provider instances
        expect(provider1, isNot(equals(provider2)));
      },
    );

    test('provider family should return same provider for same ID', () {
      final provider1 = approvalDetailControllerProvider(activityId: 1);
      final provider2 = approvalDetailControllerProvider(activityId: 1);
      // Same activity ID should return the same provider
      expect(provider1, equals(provider2));
    });
  });
}

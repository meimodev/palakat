import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _hasRegisteredInterests = false;
  bool _hasCheckedMembership = false;
  String? _lastMembershipId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Register push notification interests after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerPushNotificationInterests();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check when app comes to foreground (in case user just signed in)
    if (state == AppLifecycleState.resumed && !_hasRegisteredInterests) {
      _registerPushNotificationInterests();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if membership has changed (e.g., after sign-in or sign-out)
    final localStorage = ref.read(localStorageServiceProvider);
    final currentMembershipId = localStorage.currentMembership?.id?.toString();

    // Reset registration state if membership changed (including logout)
    if (_lastMembershipId != currentMembershipId) {
      _lastMembershipId = currentMembershipId;
      _hasRegisteredInterests = false;
      _hasCheckedMembership = false;
    }

    // This runs every time the widget is rebuilt due to navigation
    // Check if we need to register interests (e.g., after sign-in)
    if (!_hasCheckedMembership) {
      _hasCheckedMembership = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _registerPushNotificationInterests();
      });
    }
  }

  /// Registers push notification interests if user is signed in.
  ///
  /// This method checks if the user has a valid membership in local storage
  /// and registers device interests for push notifications.
  ///
  /// **Validates: Requirements 3.2**
  Future<void> _registerPushNotificationInterests() async {
    // Prevent duplicate registration
    if (_hasRegisteredInterests) {
      return;
    }

    final localStorage = ref.read(localStorageServiceProvider);
    final membership = localStorage.currentMembership;
    final account = localStorage.currentAuth?.account;

    // Only register if user has a valid membership
    if (membership != null && membership.id != null) {
      try {
        final pusherBeamsController = ref.read(
          pusherBeamsControllerProvider.notifier,
        );
        // Pass account explicitly since membership.account might be null
        await pusherBeamsController.registerInterests(
          membership,
          account: account,
        );
        _hasRegisteredInterests = true;
      } catch (e) {
        // Log error but don't block the UI
        debugPrint('🔔 [HomeScreen] Push notification registration failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(homeControllerProvider.notifier);
    final state = ref.watch(homeControllerProvider);
    final localStorage = ref.watch(localStorageServiceProvider);
    final hasAuth = localStorage.currentAuth?.account != null;

    final allowedIndices = hasAuth ? const [0, 1, 2, 3, 4] : const [0, 1, 4];
    if (!allowedIndices.contains(state.selectedBottomNavIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.navigateTo(0);
      });
    }

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      disablePadding: true,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, _) {
          if (state.selectedBottomNavIndex != 0) {
            controller.navigateTo(0);
          } else {
            DateTime now = DateTime.now();

            if (state.currentBackPressTime == null ||
                now.difference(state.currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              controller.setCurrentBackPressTime(now);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.msg_pressBackToExit,
                    style: BaseTypography.titleMedium,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          }
        },
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: PageView(
                allowImplicitScrolling: false,
                physics: const NeverScrollableScrollPhysics(),
                controller: state.pageController,
                children: const [
                  DashboardScreen(),
                  SongBookScreen(),
                  OperationsScreen(),
                  ApprovalScreen(),
                  ArticlesListScreen(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                currentIndex: state.selectedBottomNavIndex,
                onPressedItem: (index) {
                  controller.navigateTo(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

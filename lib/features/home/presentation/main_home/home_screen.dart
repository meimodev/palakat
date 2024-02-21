import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/button/button_widget.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/features/presentation.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.globalKeyOne,
    required this.globalKeyTwo,
    required this.tutorialStatus,
  });

  final GlobalKey globalKeyOne;
  final GlobalKey globalKeyTwo;
  final bool tutorialStatus;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeController get controller => ref.read(homeControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.tutorialStatus) {
        Future.delayed(const Duration(seconds: 2), () {
          controller.scrollController.position.ensureVisible(
            controller.itemKey.currentContext!.findRenderObject()!,
            alignment: 0.0,
          );
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    return Stack(
      children: <Widget>[
        Assets.images.homeBg.image(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: controller.handleRefresh,
              child: ListView(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Gap.h28,
                        SizedBox(
                          width: 148,
                          height: 50,
                          child: Assets.images.logoWithText.image(
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        if (controller.authService.isLoggedIn)
                          TodayAppointmentsWidget(
                            appointments: state.todayAppointments,
                            isGpsEnabled: state.isGpsEnabled,
                            isLoadingAppointment: state.isLoadingAppointment,
                            isLoadingSelfCheckin: state.isLoadingSelfCheckin,
                          ),
                        SizedBox(
                          key: controller.itemKey,
                        ),
                      ],
                    ),
                  ),
                  Gap.h72,
                  SizedBox(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(color: Colors.white),
                          padding: EdgeInsets.symmetric(
                            horizontal: BaseSize.w20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Gap.h72,
                              ServiceListWidget(
                                key: widget.globalKeyTwo,
                              ),
                              Gap.h36,
                              const NewsAndSpecialOffersWidget(),
                              Gap.h36,
                              const OurHospitalListWidget(),
                              Gap.h36,
                              const HealthArticleListWidget(),
                              Gap.h36,
                            ],
                          ),
                        ),
                        Positioned(
                          top: -45,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: BaseSize.w20),
                            child: CTABookWidget(
                              key: widget.globalKeyOne,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

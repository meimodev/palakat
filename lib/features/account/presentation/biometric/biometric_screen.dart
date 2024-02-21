import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricScreen extends ConsumerStatefulWidget {
  const BiometricScreen({super.key});

  @override
  ConsumerState<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends ConsumerState<BiometricScreen> {
  BiometricController get controller => ref.read(
        biometricControllerProvider(context).notifier,
      );

  @override
  void initState() {
    safeRebuild(() {
      ref.read(biometricControllerProvider(context).notifier).init();
    });
    super.initState();
  }

  Widget _renderListBiometric(
    BiometricState state,
  ) {
    String title = listEquals([BiometricType.face], state.biometricType)
        ? LocaleKeys.text_faceId.tr()
        : (listEquals([BiometricType.fingerprint], state.biometricType)
            ? LocaleKeys.text_fingerprint.tr()
            : LocaleKeys.text_biometric.tr());

    return BiometricTile(
      icon: listEquals([BiometricType.face], state.biometricType)
          ? Assets.icons.line.faceId.svg(
              width: BaseSize.w32,
              height: BaseSize.w32,
            )
          : Assets.icons.line.fingerprint.svg(
              width: BaseSize.w32,
              height: BaseSize.w32,
            ),
      title: title,
      subtitle: LocaleKeys.prefix_simplifyYourLogin.tr(
        namedArgs: {
          "value": title,
        },
      ),
      switchValue: state.enableBiometric,
      switchOnChange: (val) => controller.setBiometric(val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(biometricControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_biometricSecurity.tr(),
      ),
      child: SafeArea(
        child: LoadingWrapper(
          value: state.isLoading,
          child: Column(
            children: [
              _renderListBiometric(state),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class VerificationEmailScreen extends ConsumerStatefulWidget {
  const VerificationEmailScreen({
    super.key,
    required this.email,
    required this.token,
  });
  final String email, token;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState
    extends ConsumerState<VerificationEmailScreen> {
  VerificationEmailController get controller =>
      ref.read(verificationEmailControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.email, widget.token));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const ScaffoldWidget(
      child: LoadingWrapper(
        value: true,
        child: SizedBox(),
      ),
    );
  }
}

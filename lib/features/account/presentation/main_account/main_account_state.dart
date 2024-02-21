import 'package:halo_hermina/core/assets/assets.gen.dart';

class MainAccountState {
  final String? version;
  final bool isLoadingResend;

  const MainAccountState({
    this.version,
    this.isLoadingResend = false,
  });

  MainAccountState copyWith({
    String? version,
    bool? isLoadingResend,
  }) {
    return MainAccountState(
      version: version ?? this.version,
      isLoadingResend: isLoadingResend ?? this.isLoadingResend,
    );
  }
}

class AccountMenuModel {
  final SvgGenImage icon;
  final String title;
  final String? route;
  final Function()? onTap;

  const AccountMenuModel({
    required this.icon,
    required this.title,
    this.route,
    this.onTap,
  });
}

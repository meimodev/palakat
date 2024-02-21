// import 'package:halo_hermina/core/localization/localization.dart';
// import 'package:halo_hermina/core/widgets/widgets.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class PermissionUtil {
//   static Future<bool> request(Permission permission) async {
//     bool isGranted = await permission.isGranted;
//     if (isGranted) return true;
//
//     var status = await permission.request();
//
//     if (status.isDenied || status.isLimited) {
//       Snackbar.warning(
//         message: LocaleKeys.suffix_required.tr(namedArgs: {
//           "value": permission.toString().replaceAll("Permission.", ""),
//         }),
//       );
//       return await request(permission);
//     }
//
//     if (status.isPermanentlyDenied) {
//       Snackbar.warning(
//         message: LocaleKeys.suffix_required.tr(namedArgs: {
//           "value": permission.toString().replaceAll("Permission.", ""),
//         }),
//       );
//       return await openAppSettings();
//     }
//
//     if (status.isRestricted) {
//       Snackbar.warning(
//         message: LocaleKeys.suffix_required.tr(namedArgs: {
//           "value": permission.toString().replaceAll("Permission.", ""),
//         }),
//       );
//       return false;
//     }
//
//     return true;
//   }
// }

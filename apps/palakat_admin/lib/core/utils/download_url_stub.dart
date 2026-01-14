import 'package:url_launcher/url_launcher.dart';

Future<void> triggerBrowserDownload(Uri uri, {String? filename}) async {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

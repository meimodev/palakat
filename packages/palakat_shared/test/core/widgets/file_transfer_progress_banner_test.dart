import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_shared/core/services/file_transfer_progress_service.dart';
import 'package:palakat_shared/core/widgets/file_transfer_progress_banner.dart';

void main() {
  testWidgets('does not build Tooltip when Overlay is missing', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(fileTransferProgressControllerProvider.notifier)
        .start(
          direction: FileTransferDirection.download,
          totalBytes: 100,
          label: 'test-file',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Localizations(
          locale: const Locale('en'),
          delegates: GlobalMaterialLocalizations.delegates,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Theme(
              data: ThemeData(),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: FileTransferProgressBanner(child: SizedBox.shrink()),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Tooltip), findsNothing);

    final closeButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.close),
    );
    expect(closeButton.tooltip, isNull);
  });
}

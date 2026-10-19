import 'package:fl_clash/manager/app_manager.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/developer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';

void main() {
  setUpAll(() {
    globalState.appEnv = 'stable';
    globalState.packageInfo = PackageInfo(
      appName: 'Flc',
      packageName: 'com.follow.clash',
      version: '0.8.98',
      buildNumber: '2026091401',
    );
  });

  testWidgets('stable About keeps branding and developer access', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);

    Future<void> show(Widget child) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: AppEnvManager(child: child)),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(const AboutView());
    expect(find.text('FlClash'), findsOneWidget);
    expect(find.text('0.8.98'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppEnvManager),
        matching: find.byType(Banner),
      ),
      findsNothing,
    );
    expect(container.read(appSettingProvider).developerMode, isFalse);
    for (var tap = 0; tap < 5; tap++) {
      await tester.tap(find.byType(Image));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(container.read(appSettingProvider).developerMode, isTrue);

    await show(const DeveloperView());
    expect(find.text('Crash test'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

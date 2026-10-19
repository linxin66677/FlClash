import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/about.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';

void main() {
  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'Flc',
      packageName: 'com.follow.clash',
      version: '0.8.98',
      buildNumber: '2026091401',
    );
  });

  testWidgets('ignores automatic and manual app update results', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(appSettingProvider, (_, _) {}, fireImmediately: true);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(autoCheckUpdate: true));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: SizedBox.shrink())),
      ),
    );
    final action = container.read(commonActionProvider.notifier);
    expect(await action.autoCheckUpdate(), isFalse);
    expect(await request.checkForUpdate(), isNull);
    for (final manual in [false, true]) {
      await action.checkUpdateResultHandle(
        data: {'tag_name': 'v99.0.0', 'body': 'New release'},
        isUser: manual,
      );
      await action.checkUpdateResultHandle(isUser: manual);
    }
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('v99.0.0'), findsNothing);
    expect(container.read(appSettingProvider).autoCheckUpdate, isTrue);
  });

  testWidgets('about retains branding and version without update controls', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(locale: Locale('zh', 'CN'), child: AboutView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('FlClash'), findsOneWidget);
    expect(find.text('0.8.98'), findsOneWidget);
    expect(find.text('基于ClashMeta的多平台代理客户端，简单易用，开源无广告。'), findsOneWidget);
    expect(find.text('Telegram'), findsNothing);
    expect(find.text('检查更新'), findsNothing);
  });
}

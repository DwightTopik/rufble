import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rufble/app/app_widget.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppWidget(skipSplashDelay: true)),
    );
    // The goals screen shows a CupertinoActivityIndicator while the Drift
    // stream loads; it animates continuously, so pumpAndSettle never settles.
    // Pump a few fixed frames instead to let the first build complete.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}

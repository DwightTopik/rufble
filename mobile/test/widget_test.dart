import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rufble/app/app_widget.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppWidget(skipSplashDelay: true)),
    );
    await tester.pumpAndSettle();
  });
}

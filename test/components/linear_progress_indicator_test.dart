import 'package:flutter_test/flutter_test.dart';
import 'package:tf_shadcn_flutter/shadcn_flutter.dart';

import '../test_helper.dart';

void main() {
  group('LinearProgressIndicator', () {
    testWidgets('accepts progress gradient in determinate mode',
        (tester) async {
      const gradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const SimpleApp(
          child: LinearProgressIndicator(
            value: 0.6,
            progressGradient: gradient,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders with progress gradient in RTL mode', (tester) async {
      const gradient = LinearGradient(
        colors: [Colors.orange, Colors.purple],
      );

      await tester.pumpWidget(
        const SimpleApp(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: LinearProgressIndicator(
              value: 0.4,
              progressGradient: gradient,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports gradient with sparks during value transition',
        (tester) async {
      const gradient = LinearGradient(
        colors: [Colors.teal, Colors.cyan],
      );

      await tester.pumpWidget(
        const SimpleApp(
          child: LinearProgressIndicator(
            value: 0.2,
            progressGradient: gradient,
            showSparks: true,
          ),
        ),
      );

      await tester.pumpWidget(
        const SimpleApp(
          child: LinearProgressIndicator(
            value: 0.8,
            progressGradient: gradient,
            showSparks: true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('supports gradient in indeterminate mode with sparks',
        (tester) async {
      const gradient = LinearGradient(
        colors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(
        const SimpleApp(
          child: LinearProgressIndicator(
            progressGradient: gradient,
            showSparks: true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

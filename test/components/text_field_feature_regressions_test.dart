import 'package:flutter_test/flutter_test.dart';
import 'package:tf_shadcn_flutter/shadcn_flutter.dart';

import '../test_helper.dart';

class _FeatureInitCounter {
  static int a = 0;
  static int b = 0;
  static int c = 0;

  static void reset() {
    a = 0;
    b = 0;
    c = 0;
  }
}

class _FeatureA extends InputFeature {
  const _FeatureA();

  @override
  InputFeatureState createState() => _FeatureAState();
}

class _FeatureAState extends InputFeatureState<_FeatureA> {
  @override
  void initState() {
    super.initState();
    _FeatureInitCounter.a++;
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    yield const SizedBox.shrink();
  }
}

class _FeatureB extends InputFeature {
  const _FeatureB();

  @override
  InputFeatureState createState() => _FeatureBState();
}

class _FeatureBState extends InputFeatureState<_FeatureB> {
  @override
  void initState() {
    super.initState();
    _FeatureInitCounter.b++;
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    yield const SizedBox.shrink();
  }
}

class _FeatureC extends InputFeature {
  const _FeatureC();

  @override
  InputFeatureState createState() => _FeatureCState();
}

class _FeatureCState extends InputFeatureState<_FeatureC> {
  @override
  void initState() {
    super.initState();
    _FeatureInitCounter.c++;
  }

  @override
  Iterable<Widget> buildTrailing() sync* {
    yield const SizedBox.shrink();
  }
}

void main() {
  group('TextField feature regressions', () {
    testWidgets('reuses existing feature states when list shape changes',
        (tester) async {
      _FeatureInitCounter.reset();
      final controller = TextEditingController(text: 'value');

      await tester.pumpWidget(
        SimpleApp(
          child: TextField(
            controller: controller,
            features: const [
              _FeatureA(),
              _FeatureB(),
            ],
          ),
        ),
      );

      expect(_FeatureInitCounter.a, 1);
      expect(_FeatureInitCounter.b, 1);
      expect(_FeatureInitCounter.c, 0);

      await tester.pumpWidget(
        SimpleApp(
          child: TextField(
            controller: controller,
            features: const [
              _FeatureC(),
              _FeatureA(),
              _FeatureB(),
            ],
          ),
        ),
      );

      expect(_FeatureInitCounter.a, 1);
      expect(_FeatureInitCounter.b, 1);
      expect(_FeatureInitCounter.c, 1);
    });

    testWidgets(
        'keeps caret visible after refocus with focused trailing feature',
        (tester) async {
      final controller = TextEditingController(
        text: 'This is a very long input value to force horizontal scrolling.',
      );

      await tester.pumpWidget(
        SimpleApp(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 220,
                  child: TextField(
                    controller: controller,
                    features: [
                      InputFeature.clear(
                        visibility: InputFeatureVisibility.focused &
                            InputFeatureVisibility.textNotEmpty,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
      await tester.pump();

      await tester.tapAt(const Offset(5, 5));
      await tester.pump();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      final editableState = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      final renderEditable = editableState.renderEditable;
      final caretLocalRect =
          renderEditable.getLocalRectForCaret(controller.selection.extent);
      final caretGlobalRect =
          caretLocalRect.shift(renderEditable.localToGlobal(Offset.zero));

      final clearIconFinder = find.byIcon(LucideIcons.x);
      expect(clearIconFinder, findsOneWidget);
      final clearRect = tester.getRect(clearIconFinder);

      expect(caretGlobalRect.right <= clearRect.left, isTrue);
    });
  });
}

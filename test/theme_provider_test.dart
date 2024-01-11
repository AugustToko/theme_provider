import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';

class AppThemeOptionsTester implements AppThemeOptions {

  AppThemeOptionsTester(this.color);
  final Color color;
}

void main() {
  test('ThemeProvider constructor theme list test', () {
    final buildWidgetTree = (final List<AppTheme>? appThemes) async => ThemeProvider(
          themes: appThemes,
          child: MaterialApp(
            home: ThemeConsumer(child: Container()),
          ),
        );

    expect(() => buildWidgetTree(null), isNotNull);
    expect(() => buildWidgetTree([]), throwsAssertionError);
    expect(() => buildWidgetTree([AppTheme.light()]), throwsAssertionError);
    expect(buildWidgetTree([AppTheme.light(), AppTheme.light()]), isNotNull);

    expect(() => buildWidgetTree([AppTheme.light(), AppTheme.light(id: '')]),
        throwsAssertionError);
    expect(
        () => buildWidgetTree(
            [AppTheme.light(), AppTheme.light(id: 'no spaces')]),
        throwsAssertionError);
    expect(
        () =>
            buildWidgetTree([AppTheme.light(), AppTheme.light(id: 'No_Upper')]),
        throwsAssertionError);
    expect(
        () => buildWidgetTree([AppTheme.light(), AppTheme.light(id: 'ok_id')]),
        isNotNull);
  });

  testWidgets('ThemeProvider ancestor test', (final tester) async {
    final Key scaffoldKey = UniqueKey();

    await tester.pumpWidget(
      ThemeProvider(
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(key: scaffoldKey),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(
        find.ancestor(
          of: find.byKey(scaffoldKey),
          matching: find.byType(ThemeProvider),
        ),
        findsWidgets);
  });

  testWidgets('Basic Theme Change test', (final tester) async {
    final Key buttonKey = UniqueKey();

    await tester.pumpWidget(
      ThemeProvider(
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(
              body: Builder(
                builder: (final context) => TextButton(
                  key: buttonKey,
                  child: Text('Press Me'),
                  onPressed: () {
                    final ThemeController controller =
                        ThemeProvider.controllerOf(context);
                    controller.nextTheme();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(Theme.of(tester.element(find.byKey(buttonKey))).brightness,
        equals(Brightness.light));

    await tester.tap(find.byKey(buttonKey));
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.byKey(buttonKey))).brightness,
        equals(Brightness.dark));
  });

  testWidgets('Basic Theme Change test', (final tester) async {
    final Key scaffoldKey = UniqueKey();

    await tester.pumpWidget(
      ThemeProvider(
        themes: [
          AppTheme.light().copyWith(
            id: 'light_theme',
            options: AppThemeOptionsTester(Colors.blue),
          ),
          AppTheme.dark().copyWith(
            id: 'dark_theme',
            options: AppThemeOptionsTester(Colors.red),
          )
        ],
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(key: scaffoldKey),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
        ThemeProvider.optionsOf<AppThemeOptionsTester>(
                tester.element(find.byKey(scaffoldKey)))
            .color,
        isNot(Colors.red));
    expect(
        ThemeProvider.optionsOf<AppThemeOptionsTester>(
                tester.element(find.byKey(scaffoldKey)))
            .color,
        equals(Colors.blue));
  });

  testWidgets('Default Theme Id Test', (final tester) async {
    final Key scaffoldKey = UniqueKey();

    await tester.pumpWidget(
      ThemeProvider(
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(key: scaffoldKey),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey))).id,
        startsWith('default_'));
  });

  testWidgets('Duplicate Theme Id Test', (final tester) async {
    final errorHandled = expectAsync0(() {});

    FlutterError.onError = (final errorDetails) {
      errorHandled();
    };

    await tester.pumpWidget(
      ThemeProvider(
        themes: [
          AppTheme.light(),
          AppTheme.light(id: 'test_theme'),
          AppTheme.light(id: 'test_theme'),
        ],
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(),
          ),
        ),
      ),
    );
  });

  testWidgets('Select by Theme Id Test', (final tester) async {
    final Key scaffoldKey = UniqueKey();

    final fetchCommand = () =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));
    final fetchTheme =
        () => ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));

    await tester.pumpWidget(
      ThemeProvider(
        themes: [
          AppTheme.light(),
          AppTheme.light(id: 'test_theme_1'),
          AppTheme.light(id: 'test_theme_2'),
          AppTheme.light(id: 'test_theme_random'),
        ],
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(key: scaffoldKey),
          ),
        ),
      ),
    );
    expect(fetchTheme().id, equals('default_light_theme'));

    fetchCommand().nextTheme();
    expect(fetchTheme().id, equals('test_theme_1'));

    fetchCommand().setTheme('test_theme_random');
    expect(fetchTheme().id, equals('test_theme_random'));
  });
  testWidgets('Set default theme id test', (final tester) async {
    final Key scaffoldKey = UniqueKey();

    final getCurrentThemeId =
        () => ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey))).id;

    final widgetTreeWithDefaultTheme =
        ({final String? defaultTheme}) async => await tester.pumpWidget(
              ThemeProvider(
                defaultThemeId: defaultTheme,
                themes: [
                  AppTheme.light(),
                  AppTheme.light(id: 'test_theme_1'),
                  AppTheme.light(id: 'test_theme_2'),
                  AppTheme.light(id: 'test_theme_3'),
                  AppTheme.light(id: 'test_theme_4'),
                ],
                child: MaterialApp(
                  home: ThemeConsumer(
                    child: Scaffold(key: scaffoldKey),
                  ),
                ),
              ),
            );

    await widgetTreeWithDefaultTheme();
    expect(getCurrentThemeId(), equals('default_light_theme'));

    await widgetTreeWithDefaultTheme(defaultTheme: 'test_theme_3');
    expect(getCurrentThemeId(), equals('test_theme_3'));

    final errorHandled = expectAsync0(() {});

    FlutterError.onError = (final errorDetails) {
      errorHandled();
    };

    await widgetTreeWithDefaultTheme(defaultTheme: 'no_theme');
  });

  testWidgets('Persistence widget test', (final tester) async {
    SharedPreferences.setMockInitialValues(Map());

    final buildWidgetTree = (final Key scaffoldKey) async {
      await tester.pumpWidget(
        ThemeProvider(
          defaultThemeId: 'test_theme_1',
          saveThemesOnChange: true,
          themes: [
            AppTheme.light(id: 'test_theme_1'),
            AppTheme.light(id: 'test_theme_2'),
            AppTheme.light(id: 'test_theme_3'),
            AppTheme.light(id: 'test_theme_4'),
          ],
          child: MaterialApp(
            home: ThemeConsumer(
              child: Scaffold(key: scaffoldKey),
            ),
          ),
        ),
      );
    };

    final getCurrentTheme = (final Key scaffoldKey) =>
        ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));
    final getCurrentController = (final Key scaffoldKey) =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));

    final Key scaffoldKey1 = UniqueKey();
    await buildWidgetTree(scaffoldKey1);
    expect(getCurrentTheme(scaffoldKey1).id, 'test_theme_1');
    getCurrentController(scaffoldKey1).setTheme('test_theme_3');
    expect(getCurrentTheme(scaffoldKey1).id, 'test_theme_3');

    await tester.pump();

    final Key scaffoldKey2 = UniqueKey();
    await buildWidgetTree(scaffoldKey2);
    await tester.pump();
    expect(getCurrentTheme(scaffoldKey2).id, 'test_theme_1');

    await getCurrentController(scaffoldKey2).loadThemeFromDisk();
    expect(getCurrentTheme(scaffoldKey2).id, 'test_theme_3');
  });

  testWidgets('Persistence widget set theme on init test', (final tester) async {
    SharedPreferences.setMockInitialValues(Map());

    final buildWidgetTree = (final Key scaffoldKey) async {
      await tester.pumpWidget(
        ThemeProvider(
          defaultThemeId: 'second_test_theme_1',
          saveThemesOnChange: true,
          themes: [
            AppTheme.light(id: 'second_test_theme_1'),
            AppTheme.light(id: 'second_test_theme_2'),
            AppTheme.light(id: 'second_test_theme_3'),
          ],
          onInitCallback: (final controller, final previouslySavedThemeFuture) async {
            final String? savedTheme = await previouslySavedThemeFuture;
            if (savedTheme != null) {
              controller.setTheme(savedTheme);
            }
          },
          child: MaterialApp(
            home: ThemeConsumer(
              child: Scaffold(key: scaffoldKey),
            ),
          ),
        ),
      );
    };

    final getCurrentTheme = (final Key scaffoldKey) =>
        ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));
    final getCurrentController = (final Key scaffoldKey) =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));

    final Key scaffoldKey1 = UniqueKey();
    await buildWidgetTree(scaffoldKey1);
    expect(getCurrentTheme(scaffoldKey1).id, 'second_test_theme_1');
    getCurrentController(scaffoldKey1).setTheme('second_test_theme_3');
    expect(getCurrentTheme(scaffoldKey1).id, 'second_test_theme_3');

    await tester.pump();

    final Key scaffoldKey2 = UniqueKey();
    await buildWidgetTree(scaffoldKey2);
    await tester.pump();
    expect(getCurrentTheme(scaffoldKey2).id, 'second_test_theme_3');
  });

  testWidgets('On theme changed callback test', (final tester) async {
    var _oldThemeId;
    var _currentThemeId = 'second_test_theme_1';

    final buildWidgetTree = (final Key scaffoldKey) async {
      await tester.pumpWidget(
        ThemeProvider(
          defaultThemeId: _currentThemeId,
          themes: [
            AppTheme.light(id: 'second_test_theme_1'),
            AppTheme.light(id: 'second_test_theme_2'),
            AppTheme.light(id: 'second_test_theme_3'),
          ],
          onThemeChanged: (final oldTheme, final newTheme) {
            _oldThemeId = oldTheme.id;
            _currentThemeId = newTheme.id;
          },
          child: MaterialApp(
            home: ThemeConsumer(
              child: Scaffold(key: scaffoldKey),
            ),
          ),
        ),
      );
    };

    final getCurrentTheme = (final Key scaffoldKey) =>
        ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));
    final getCurrentController = (final Key scaffoldKey) =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));

    final Key scaffoldKey1 = UniqueKey();
    await buildWidgetTree(scaffoldKey1);

    expect(_oldThemeId, isNull);
    expect(getCurrentTheme(scaffoldKey1).id, equals(_currentThemeId));

    getCurrentController(scaffoldKey1).setTheme('second_test_theme_3');

    expect(_oldThemeId, equals('second_test_theme_1'));
    expect(_currentThemeId, equals('second_test_theme_3'));
    expect(getCurrentTheme(scaffoldKey1).id, equals(_currentThemeId));

    await tester.pump();
  });

  testWidgets('Persistence auto load parameter', (final tester) async {
    SharedPreferences.setMockInitialValues(Map());

    final buildWidgetTree = (final Key scaffoldKey) async {
      await tester.pumpWidget(
        ThemeProvider(
          defaultThemeId: 'third_test_theme_1',
          saveThemesOnChange: true,
          themes: [
            AppTheme.light(id: 'third_test_theme_1'),
            AppTheme.light(id: 'third_test_theme_2'),
            AppTheme.light(id: 'third_test_theme_3'),
          ],
          loadThemeOnInit: true,
          child: MaterialApp(
            home: ThemeConsumer(
              child: Scaffold(key: scaffoldKey),
            ),
          ),
        ),
      );
    };

    final getCurrentTheme = (final Key scaffoldKey) =>
        ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));
    final getCurrentController = (final Key scaffoldKey) =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));

    final Key scaffoldKey1 = UniqueKey();
    await buildWidgetTree(scaffoldKey1);
    expect(getCurrentTheme(scaffoldKey1).id, 'third_test_theme_1');
    getCurrentController(scaffoldKey1).setTheme('third_test_theme_3');
    expect(getCurrentTheme(scaffoldKey1).id, 'third_test_theme_3');

    await tester.pump();

    final Key scaffoldKey2 = UniqueKey();
    await buildWidgetTree(scaffoldKey2);
    await tester.pump();
    expect(getCurrentTheme(scaffoldKey2).id, 'third_test_theme_3');
  });

  testWidgets('Multiple Theme Providers', (final tester) async {
    SharedPreferences.setMockInitialValues(Map());

    final buildWidgetTree = (final Key scaffoldKey, final String providerId) async {
      await tester.pumpWidget(
        ThemeProvider(
          providerId: providerId,
          defaultThemeId: 'fourth_test_theme_1',
          saveThemesOnChange: true,
          loadThemeOnInit: true,
          themes: [
            AppTheme.light(id: 'fourth_test_theme_1'),
            AppTheme.light(id: 'fourth_test_theme_2'),
            AppTheme.light(id: 'fourth_test_theme_3'),
          ],
          child: MaterialApp(
            home: ThemeConsumer(
              child: Scaffold(key: scaffoldKey),
            ),
          ),
        ),
      );
    };

    final getCurrentTheme = (final Key scaffoldKey) =>
        ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));
    final getCurrentController = (final Key scaffoldKey) =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));

    final Key scaffoldKey1 = UniqueKey();
    const String firstId = 'A';
    await buildWidgetTree(scaffoldKey1, firstId);
    expect(getCurrentTheme(scaffoldKey1).id, 'fourth_test_theme_1');
    getCurrentController(scaffoldKey1).setTheme('fourth_test_theme_3');
    expect(getCurrentTheme(scaffoldKey1).id, 'fourth_test_theme_3');

    final Key scaffoldKey2 = UniqueKey();
    const String secondId = 'B';
    await buildWidgetTree(scaffoldKey2, secondId);
    expect(getCurrentTheme(scaffoldKey2).id, 'fourth_test_theme_1');
    getCurrentController(scaffoldKey2).setTheme('fourth_test_theme_2');
    expect(getCurrentTheme(scaffoldKey2).id, 'fourth_test_theme_2');

    await tester.pump();

    final Key scaffoldKey3 = UniqueKey();
    await buildWidgetTree(scaffoldKey3, firstId);
    await tester.pump();
    expect(getCurrentTheme(scaffoldKey3).id, 'fourth_test_theme_3');

    final Key scaffoldKey4 = UniqueKey();
    await buildWidgetTree(scaffoldKey4, secondId);
    await tester.pump();
    expect(getCurrentTheme(scaffoldKey4).id, 'fourth_test_theme_2');
  });

  testWidgets('Dynamically theme adding/removing/membership checking',
      (final tester) async {
    final Key scaffoldKey = UniqueKey();

    final fetchCommand = () =>
        ThemeProvider.controllerOf(tester.element(find.byKey(scaffoldKey)));
    final fetchTheme =
        () => ThemeProvider.themeOf(tester.element(find.byKey(scaffoldKey)));

    final AppTheme customTheme = AppTheme.light(id: 'custom');

    await tester.pumpWidget(
      ThemeProvider(
        themes: [
          AppTheme.light(),
          AppTheme.light(id: 'test_theme_1'),
          AppTheme.light(id: 'test_theme_2'),
        ],
        child: MaterialApp(
          home: ThemeConsumer(
            child: Scaffold(key: scaffoldKey),
          ),
        ),
      ),
    );
    expect(fetchTheme().id, equals('default_light_theme'));

    fetchCommand().nextTheme();
    expect(fetchTheme().id, equals('test_theme_1'));

    expect(fetchCommand().hasTheme('custom'), equals(false));
    expect(() => fetchCommand().removeTheme('custom'), throwsException);

    fetchCommand().addTheme(customTheme);
    expect(fetchTheme().id, equals('test_theme_1'));
    expect(fetchCommand().hasTheme('custom'), equals(true));
    expect(() => fetchCommand().addTheme(customTheme), throwsException);

    fetchCommand().setTheme('custom');
    expect(fetchTheme().id, equals('custom'));

    expect(fetchCommand().hasTheme('custom'), equals(true));
    expect(() => fetchCommand().removeTheme('custom'), throwsException);

    fetchCommand().nextTheme();
    fetchCommand().removeTheme('custom');

    expect(fetchCommand().hasTheme('custom'), equals(false));
  });
}

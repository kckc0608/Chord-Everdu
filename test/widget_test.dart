// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/page/common_widget/loading_circle.dart';
import 'package:chord_everdu/page/search_sheet/search_sheet.dart';
import 'package:chord_everdu/page/search_sheet/widget/new_sheet_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chord_everdu/main.dart';
import 'package:provider/provider.dart';

import 'mock.dart';

void main() {

  setupFirebaseAuthMock();

  // setUpAll(() async {
  //   await Firebase.initializeApp();
  // });

  testWidgets('new sheet dialog create test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Sheet()),
      ],
      child: MyApp(firebaseApp: Firebase.initializeApp()),
    ));

    expect(find.byType(LoadingCircle), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 50));

    expect(find.byType(SearchSheet), findsOneWidget);

    // Verify that there is new sheet floating button
    //expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    // await tester.runAsync(() async {
    //
    // });

    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pumpAndSettle(Duration(seconds: 1));
    //
    // // expect(find.text('새 악보'), findsOneWidget);
    // expect(find.byType(NewSheetDialog), findsOneWidget);
  });
}

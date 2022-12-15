// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility that Flutter provides. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter_test/flutter_test.dart';
// import 'package:exchangilymobileapp/main.dart';
// import 'package:provider/provider.dart';
// import 'package:exchangilymobileapp/enums/connectivity_status.dart';
// import 'package:package_info/package_info.dart';
// import 'package:flutter/material.dart';
//
// Future<void> main() async {
//   testWidgets('MyApp test', (WidgetTester tester) async {
//     // Create a PackageInfo object to pass to the MyApp widget
//     var packageInfo = PackageInfo(
//       appName: 'Exchangily',
//       packageName: 'com.exchangily.mobile',
//       version: '1.0.0',
//       buildNumber: '1',
//     );
//
//     // Build the MyApp widget
//     await tester.pumpWidget(
//       MyApp(packageInfo),
//     );
//
//     // Verify that the MyApp widget contains a MaterialApp widget
//     expect(find.byType(MaterialApp), findsOneWidget);
//
//     // expect(find.byType(MaterialApp), findsOneWidget);
//
//     // Use the StreamProvider to update the connectivity status
//     await tester.pumpWidget(
//       StreamProvider<ConnectivityStatus>(
//         create: (_) => Stream.value(ConnectivityStatus.Offline),
//         child: MyApp(packageInfo),
//       ),
//     );
//     // Provider.of<ConnectivityStatus>(tester.element(find.byType(MaterialApp)),
//     // listen: false);
//
//     // Rebuild the widget to reflect the updated connectivity status
//     await tester.pump();
//   });
// }

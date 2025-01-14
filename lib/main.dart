/*
* Copyright (c) 2020 Exchangily LLC
*
* Licensed under Apache License v2.0
* You may obtain a copy of the License at
*
*      https://www.apache.org/licenses/LICENSE-2.0
*
*----------------------------------------------------------------------
* Author: barry-ruprai@exchangily.com
*----------------------------------------------------------------------
*/

import 'package:exchangilymobileapp/Managers/dialog_manager.dart';
import 'package:exchangilymobileapp/Managers/life_cycle_manager.dart';
import 'package:exchangilymobileapp/enums/connectivity_status.dart';
import 'package:exchangilymobileapp/routes.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/connectivity_service.dart';
import 'package:exchangilymobileapp/services/navigation_service.dart';
import 'package:exchangilymobileapp/services/dialog_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import './shared/globals.dart' as globals;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;

  // debugRepaintRainbowEnabled = true;
  // isrgrootx1.pem

  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue, // navigation bar color
  //   statusBarColor: Colors.pink, // status bar color
  // ));
  // SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(statusBarColor: Colors.white));

  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await serviceLocator();
    Logger.level = Level.nothing;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // await dotenv.load();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(MyApp(packageInfo));
    });
    // await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Error in main.dart');
    debugPrint(e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp(this.packageInfo);
  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return StreamProvider(
      create: (BuildContext context) =>
          ConnectivityService().connectionStatusController.stream,
      initialData: ConnectivityStatus.Offline,
      child: LifeCycleManager(
        child: OverlaySupport(
          child: MaterialApp(
            // locale: DevicePreview.of(context).locale,
            debugShowCheckedModeBanner: false,
            navigatorKey: locator<NavigationService>().navigatorKey,
            builder: (context, widget) => Stack(
              children: [
                Navigator(
                    key: locator<DialogService>().navigatorKey,
                    onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => DialogManager(
                              child: widget,
                            ))),
                Positioned(
                    bottom: 120,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          // 'v ',
                          'v ${packageInfo.version}.${packageInfo.buildNumber}',
                          style: const TextStyle(
                              fontSize: 10, color: Color(0x44ffffff)),
                        ),
                      ),
                    ))
              ],
            ),
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            // locale: Langua,
            supportedLocales: const [
              Locale("en", ""), // English
              Locale("zh", ""), // Chinese
              Locale("hi", ""), // Hindi India
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.title,

            onGenerateRoute: RouteGenerator.generateRoute,
            title: 'Exchangily Wallet',
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              // added unselectedWidgetColor to update inactive radio button's color
              unselectedWidgetColor: Colors.white,
              disabledColor: globals.grey.withAlpha(100),
              primaryColor: globals.primaryColor,
              cardColor: globals.walletCardColor,
              canvasColor: globals.secondaryColor,
              buttonTheme: const ButtonThemeData(
                  minWidth: double.infinity,
                  buttonColor: globals.primaryColor,
                  padding: EdgeInsets.all(15),
                  shape: StadiumBorder(),
                  textTheme: ButtonTextTheme.primary),
              fontFamily: 'Roboto',
              textTheme: const TextTheme(
                  button: TextStyle(fontSize: 14, color: globals.white),
                  // displayLarge
                  headline1: TextStyle(
                      fontSize: 22,
                      color: globals.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.25),
                  headline2: TextStyle(
                      fontSize: 14,
                      color: globals.white,
                      letterSpacing: 1,
                      height: 1.5,
                      fontWeight: FontWeight.bold),
                  headline3: TextStyle(fontSize: 16, color: globals.white),
                  headline4: TextStyle(
                      fontSize: 15,
                      color: globals.white,
                      fontWeight: FontWeight.w300),
                  subtitle1: TextStyle(
                      fontSize: 14,
                      color: globals.white,
                      fontWeight: FontWeight.w300),
                  headline5: TextStyle(
                      fontSize: 12.5,
                      color: globals.white,
                      fontWeight: FontWeight.w400),
                  subtitle2: TextStyle(
                      fontSize: 10.3,
                      color: globals.grey,
                      fontWeight: FontWeight.w400),
                  bodyText1: TextStyle(
                      fontSize: 13,
                      color: globals.white,
                      fontWeight: FontWeight.w400),
                  headline6: TextStyle(
                      fontSize: 10.5,
                      color: globals.white,
                      fontWeight: FontWeight.w500)),
              colorScheme: ColorScheme.fromSwatch()
                  .copyWith(secondary: globals.secondaryColor),
            ),
            // Removed the home and scaffold because initial route has set
            initialRoute: '/',
          ),
        ),
      ),
    );
  }
}

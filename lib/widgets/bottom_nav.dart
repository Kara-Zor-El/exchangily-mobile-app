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

import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../shared/globals.dart' as globals;

class BottomNavBar extends StatelessWidget {
  final int count;
  BottomNavBar({Key key, this.count}) : super(key: key);
  final NavigationService navigationService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    final double paddingValue = 4; // change space between icon and title text
    final double iconSize = 25; // change icon size
    int _selectedIndex = count;

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      elevation: 10,
      unselectedItemColor: globals.grey,
      backgroundColor: globals.walletCardColor,
      selectedItemColor: globals.primaryColor,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.wallet, size: iconSize),
          title: Padding(
              padding: EdgeInsets.only(top: paddingValue),
              child: Text(AppLocalizations.of(context).wallet)),
        ),
        // BottomNavigationBarItem(
        //     icon: Icon(FontAwesomeIcons.chartBar, size: iconSize),
        //     title: Padding(
        //         padding: EdgeInsets.only(top: paddingValue),
        //         child: Text(AppLocalizations.of(context).market))),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.coins, size: iconSize),
            title: Padding(
                padding: EdgeInsets.only(top: paddingValue),
                child: Text(AppLocalizations.of(context).trade))),
        // BottomNavigationBarItem(
        //     icon: Icon(Icons.branding_watermark, size: iconSize),
        //     title: Padding(
        //         padding: EdgeInsets.only(top: paddingValue),
        //         child: Text('OTC'))),
        BottomNavigationBarItem(
            icon: Icon(Icons.event, size: iconSize),
            title: Padding(
                padding: EdgeInsets.only(top: paddingValue),
                child: Text(AppLocalizations.of(context).event))),

        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.cog, size: iconSize),
            title: Padding(
                padding: EdgeInsets.only(top: paddingValue),
                child: Text(AppLocalizations.of(context).settings))),
      ].toList(),
      onTap: (int idx) {
        switch (idx) {
          case 0:

            /// when user in exchangeTrade route and then click on dashboard or
            /// any bottom nav links then if i use pushReplacementNamed which is
            /// an entry animation route, then this way it closes the running web sockets
            /// automatically and everything is fine otherwise is i user popAndPushNamed here
            /// then reading from socket exception error in the terminal
            navigationService.navigateTo('/dashboard');
            break;

          case 1:
            navigationService.navigateTo('/marketsView');
            break;
          // case 2:
          //   Navigator.pushNamed(context, '/otc');
          //   break;
          case 2:
            navigationService.navigateTo('/campaignInstructions');
            break;
          case 3:
            navigationService.navigateTo('/settings');
            break;
        }
      },
    );
  }
}

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

import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/environments/environment_type.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/screen_state/base_state.dart';
import 'package:exchangilymobileapp/services/wallet_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:overlay_support/overlay_support.dart';
import '../../../logger.dart';
import '../../../service_locator.dart';

class ConfirmMnemonicScreenState extends BaseState {
  final WalletService _walletService = locator<WalletService>();
  final log = getLogger('ConfirmMnemonicScreenState');
  String errorMessage = '';
  List<String> userTypedMnemonicList = [];
  List<String> randomMnemonicList = [];
  String listToStringMnemonic = '';

  verifyMnemonic(controller, context, count, routeName) {
    userTypedMnemonicList.clear();
    for (var i = 0; i < count; i++) {
      String mnemonicWord = controller[i].text;
      userTypedMnemonicList.add(mnemonicWord.trim());
    }

    if (routeName == 'import') {
      if (userTypedMnemonicList[0] != '' &&
          userTypedMnemonicList[1] != '' &&
          userTypedMnemonicList[2] != '' &&
          userTypedMnemonicList[3] != '' &&
          userTypedMnemonicList[4] != '' &&
          userTypedMnemonicList[5] != '' &&
          userTypedMnemonicList[6] != '' &&
          userTypedMnemonicList[7] != '' &&
          userTypedMnemonicList[8] != '' &&
          userTypedMnemonicList[9] != '' &&
          userTypedMnemonicList[10] != '' &&
          userTypedMnemonicList[11] != '') {
        listToStringMnemonic = userTypedMnemonicList.join(' ');
        bool isValid = bip39.validateMnemonic(listToStringMnemonic);
        if (isValid) {
          importWallet(listToStringMnemonic, context);
        } else {
          _walletService.showInfoFlushbar(
              AppLocalizations.of(context).invalidMnemonic,
              AppLocalizations.of(context).pleaseFillAllTheTextFieldsCorrectly,
              Icons.cancel,
              Colors.red,
              context);
        }
      } else {
        _walletService.showInfoFlushbar(
            AppLocalizations.of(context).invalidMnemonic,
            AppLocalizations.of(context).pleaseFillAllTheTextFieldsCorrectly,
            Icons.cancel,
            Colors.red,
            context);
      }
    } else {
      createWallet(context);
    }
  }

  // Import Wallet

  importWallet(String stringMnemonic, context) async {
    var args = {'mnemonic': stringMnemonic, 'isImport': true};
    Navigator.of(context).pushNamed('/createPassword', arguments: args);
  }

// Create Wallet
  createWallet(context) {
    if (listEquals(randomMnemonicList, userTypedMnemonicList)) {
      listToStringMnemonic = randomMnemonicList.join(' ');
      bool isValid = bip39.validateMnemonic(listToStringMnemonic);
      if (isValid) {
        var args = {'mnemonic': listToStringMnemonic, 'isImport': false};
        Navigator.of(context).pushNamed('/createPassword', arguments: args);
      } else {
        showSimpleNotification(
            Text(AppLocalizations.of(context).invalidMnemonic,
                style:
                    Theme.of(context).textTheme.headline4.copyWith(color: red)),
            position: NotificationPosition.bottom,
            subtitle: Text(AppLocalizations.of(context)
                .pleaseFillAllTheTextFieldsCorrectly));
      }
    } else {
      showSimpleNotification(
          Text(AppLocalizations.of(context).invalidMnemonic,
              style:
                  Theme.of(context).textTheme.headline4.copyWith(color: red)),
          position: NotificationPosition.bottom,
          subtitle: Text(AppLocalizations.of(context)
              .pleaseFillAllTheTextFieldsCorrectly));
    }
  }
}

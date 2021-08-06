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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/localizations.dart';

class VerifyMnemonicWalletView extends StatelessWidget {
  final List<TextEditingController> mnemonicTextController;
  final String validationMessage;
  final int count;

  VerifyMnemonicWalletView(
      {@required this.mnemonicTextController,
      this.validationMessage,
      this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                AppLocalizations.of(context).warningImportOrConfirmMnemonic,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              )),
            ],
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
              child: GridView.extent(
                  maxCrossAxisExtent: 125,
                  padding: const EdgeInsets.all(2),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  childAspectRatio: 2,
                  children: _buildTextGrid(count, mnemonicTextController))),
        ],
      ),
    );
  }

  List<Container> _buildTextGrid(int count, controller) =>
      List.generate(count, (i) {
        var hintMnemonicWordNumber = i + 1;
        controller.add(TextEditingController());
        return Container(
            child: TextField(
          inputFormatters: <TextInputFormatter>[
            // FilteringTextInputFormatter.allow(RegExp(r'([a-z]{0,})$'))
          ],
          style: TextStyle(color: white),
          controller: controller[i],
          autocorrect: true,
          decoration: InputDecoration(
            fillColor: primaryColor,
            filled: true,
            hintText: '$hintMnemonicWordNumber',
            hintStyle: TextStyle(color: white),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: white, width: 2),
                borderRadius: BorderRadius.circular(30.0)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ));
      });
}
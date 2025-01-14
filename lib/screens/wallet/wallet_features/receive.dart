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

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:cross_file/cross_file.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/models/wallet/wallet_model.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/shared_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/globals.dart' as globals;
import 'package:exchangilymobileapp/utils/fab_util.dart';
import 'dart:async';

class ReceiveWalletScreen extends StatefulWidget {
  final WalletInfo? walletInfo;
  const ReceiveWalletScreen({Key? key, this.walletInfo}) : super(key: key);

  @override
  _ReceiveWalletScreenState createState() => _ReceiveWalletScreenState();
}

class _ReceiveWalletScreenState extends State<ReceiveWalletScreen> {
  String convertedToFabAddress = '';
  final fabUtils = FabUtils();
  @override
  void initState() {
    super.initState();
    // log.w(widget.walletInfo.toJson());
    // if (widget.walletInfo.tokenType == 'FAB') {
    //   convertedToFabAddress =
    //       fabUtils.fabToExgAddress(widget.walletInfo.address);
    //   log.w(
    //       'convertedToFabAddress from ${widget.walletInfo.address} to $convertedToFabAddress');
    // }
  }

  final log = getLogger('Receive');
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.receive,
            style: Theme.of(context).textTheme.displaySmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildCopyAddressContainer(context, walletInfo: widget.walletInfo),
              buildQrImageContainer(),
            ],
          ),
        ),
      ),
    );
  }
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                    QR Code Image and Share Button Container

--------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  Container buildQrImageContainer() {
    return Container(
      width: double.infinity,
      height: 350,
      color: globals.walletCardColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: globals.primaryColor)),
              child: Center(
                child: Container(
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: QrImage(
                        backgroundColor: globals.white,
                        data: convertedToFabAddress == ''
                            ? widget.walletInfo!.address!
                            : convertedToFabAddress,
                        version: QrVersions.auto,
                        size: 300,
                        gapless: true,
                        errorStateBuilder: (context, err) {
                          return Container(
                            child: Center(
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .somethingWentWrong,
                                  textAlign: TextAlign.center),
                            ),
                          );
                        }),
                  ),
                ),
              )),
          Container(
            padding: const EdgeInsets.all(10.0),
            // child: RaisedButton(
            //     child: Text(AppLocalizations.of(context).saveAndShareQrCode,
            //         style: Theme.of(context)
            //             .textTheme
            //             .headlineMedium
            //             .copyWith(fontWeight: FontWeight.w400)),
            //     onPressed: () {
            //       String receiveFileName = 'qr-code.png';
            //       getApplicationDocumentsDirectory().then((dir) {
            //         String filePath = "${dir.path}/$receiveFileName";
            //         File file = File(filePath);
            //
            //         Future.delayed(const Duration(milliseconds: 30), () {
            //           _capturePng().then((byteData) {
            //             file.writeAsBytes(byteData).then((onFile) {
            //               Share.shareFiles([onFile.path],
            //                   text: convertedToFabAddress == ''
            //                       ? widget.walletInfo.address
            //                       : convertedToFabAddress);
            //             });
            //           });
            //         });
            //       });
            //     }),
            // Replaced deprecated RaisedButton with ElevatedButton
            child: ElevatedButton(
                child: Text(AppLocalizations.of(context)!.saveAndShareQrCode,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w400)),
                onPressed: () {
                  String receiveFileName = 'qr-code.png';
                  getApplicationDocumentsDirectory().then((dir) {
                    String filePath = "${dir.path}/$receiveFileName";
                    File file = File(filePath);

                    Future.delayed(const Duration(milliseconds: 30), () {
                      _capturePng().then((byteData) {
                        file.writeAsBytes(byteData!).then((onFile) {
                          // use shareXFiles instead of shareFiles
                          // turn onFiles.path list into list of XFile list
                          List<XFile> xFileList = [];
                          for (String path in [onFile.path]) {
                            xFileList.add(XFile(path));
                          }
                          Share.shareXFiles(xFileList,
                              text: convertedToFabAddress == ''
                                  ? widget.walletInfo!.address
                                  : convertedToFabAddress);
                        });
                      });
                    });
                  });
                }),
          )
        ],
      ),
    );
  }

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Copy Address Build Container

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  Container buildCopyAddressContainer(BuildContext context,
      {WalletInfo? walletInfo}) {
    return Container(
      width: double.infinity,
      height: 150,
      color: globals.walletCardColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              convertedToFabAddress == ''
                  ? widget.walletInfo!.address!
                  : convertedToFabAddress,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w800)),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const StadiumBorder(
                  side: BorderSide(color: primaryColor, width: 2),
                )),
                side: MaterialStateProperty.all(
                    const BorderSide(color: primaryColor, width: 0.5)),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.content_copy,
                      size: 16,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.copyAddress,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              onPressed: () {
                copyAddress();
              },
            ),
          )
        ],
      ),
    );
  }

  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Copy Address Function

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  copyAddress() {
    String? address = convertedToFabAddress == ''
        ? widget.walletInfo!.address
        : convertedToFabAddress;
    log.w(address);
    Clipboard.setData(ClipboardData(text: address));
    SharedService sharedService = locator<SharedService>();
    sharedService.sharedSimpleNotification(
      AppLocalizations.of(context)!.addressCopied,
      isError: false,
    );
  }

  /*--------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                        Save and Share PNG

  --------------------------------------------------------------------------------------------------------------------------------------------------------------*/

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await (image.toByteData(format: ImageByteFormat.png)
          as FutureOr<ByteData>);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      return null;
    }
  }
}

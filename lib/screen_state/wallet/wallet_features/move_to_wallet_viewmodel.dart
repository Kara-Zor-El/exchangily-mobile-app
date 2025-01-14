import 'dart:io';
import 'dart:typed_data';
import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/constants/font_style.dart';
import 'package:exchangilymobileapp/environments/environment.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/models/wallet/token_model.dart';
import 'package:exchangilymobileapp/models/wallet/wallet_model.dart';
import 'package:exchangilymobileapp/service_locator.dart';
import 'package:exchangilymobileapp/services/api_service.dart';
import 'package:exchangilymobileapp/services/coin_service.dart';
import 'package:exchangilymobileapp/services/dialog_service.dart';
import 'package:exchangilymobileapp/services/shared_service.dart';
import 'package:exchangilymobileapp/services/wallet_service.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:exchangilymobileapp/utils/custom_http_util.dart';
import 'package:exchangilymobileapp/utils/string_util.dart';
import 'package:exchangilymobileapp/utils/wallet/wallet_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exchangilymobileapp/services/db/token_info_database_service.dart';
import 'dart:convert';
import 'package:exchangilymobileapp/utils/fab_util.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';

class MoveToWalletViewmodel extends BaseViewModel {
  final log = getLogger('MoveToWalletViewmodel');

  final client = CustomHttpUtil.createLetsEncryptUpdatedCertClient();
  final DialogService? _dialogService = locator<DialogService>();
  WalletService? walletService = locator<WalletService>();
  ApiService? apiService = locator<ApiService>();
  SharedService? sharedService = locator<SharedService>();
  final TokenInfoDatabaseService? tokenListDatabaseService = locator<TokenInfoDatabaseService>();
  final CoinService? coinService = locator<CoinService>();

  WalletInfo? walletInfo;
  BuildContext? context;

  String gasFeeUnit = '';
  String feeMeasurement = '';
  final kanbanGasPriceTextController = TextEditingController();
  final kanbanGasLimitTextController = TextEditingController();
  final amountController = TextEditingController();
  late var kanbanTransFee;
  var minimumAmount;
  bool transFeeAdvance = false;
  double gasAmount = 0.0;

  bool isShowErrorDetailsButton = false;
  bool isShowDetailsMessage = false;
  String? serverError = '';

  List<Map<String, dynamic>> chainBalances = [];

  var ethChainBalance;
  var fabChainBalance;
  var trxTsWalletBalance;
  var bnbTsWalletBalance;
  var polygonTsWalletBalance;

  bool isWithdrawChoice = false;

  String? _groupValue;
  get groupValue => _groupValue;

  bool isShowFabChainBalance = false;
  bool isShowTrxTsWalletBalance = false;
  bool isShowBnbTsWalletBalance = false;
  bool isShowPolygonTsWalletBalance = false;

  String? specialTicker = '';
  String? updateTickerForErc = '';

  bool isAlert = false;
  bool isSpeicalTronTokenWithdraw = false;
  String? message = '';

  bool isWithdrawChoicePopup = false;
  int decimalLimit = 6;
  String ercSmartContractAddress = '';

  TokenModel token = TokenModel();
  TokenModel ercChainToken = TokenModel();
  TokenModel bnbChainToken = TokenModel();
  TokenModel mainChainToken = TokenModel();
  TokenModel polygonChainToken = TokenModel();

  bool isSubmittingTx = false;
  var tokenType;
  var walletUtil = WalletUtil();

/*---------------------------------------------------
                      INIT
--------------------------------------------------- */

  void initState() async {
    setBusy(true);

    sharedService!.context = context;

    var gasPrice = environment["chains"]["KANBAN"]["gasPrice"];
    var gasLimit = environment["chains"]["KANBAN"]["gasLimit"];
    kanbanGasPriceTextController.text = gasPrice.toString();
    kanbanGasLimitTextController.text = gasLimit.toString();

    tokenType = walletInfo!.tokenType;

    kanbanTransFee = bigNum2Double(gasPrice * gasLimit);

    _groupValue = 'ETH';

    if (walletInfo!.tickerName == 'ETH' || walletInfo!.tickerName == 'USDT') {
      gasFeeUnit = 'WEI';
    } else if (walletInfo!.tickerName == 'FAB') {
      gasFeeUnit = 'LIU';
      feeMeasurement = '10^(-8)';
    }

    // ETH
    if (walletInfo!.tickerName == 'ETH' || walletInfo!.tokenType == 'ETH') {
      radioButtonSelection('ETH');
    }
    //FAB
    else if (walletInfo!.tickerName == 'FAB' || walletInfo!.tokenType == 'FAB') {
      isShowFabChainBalance = true;
      radioButtonSelection('FAB');
    }
    // TRX
    else if (walletInfo!.tickerName == 'USDTX' ||
        walletInfo!.tickerName == 'TRX' ||
        walletInfo!.tokenType == 'TRX') {
      isShowTrxTsWalletBalance = true;

      radioButtonSelection('TRX');
    }
    // BNB
    else if (walletInfo!.tickerName == 'FABB' ||
        walletInfo!.tickerName == 'USDTB' ||
        walletInfo!.tokenType == 'BNB') {
      isShowBnbTsWalletBalance = true;

      radioButtonSelection('BNB');
    }
    // POLYGON
    else if (walletInfo!.tokenType == 'MATICM' ||
        walletInfo!.tickerName == 'MATICM' ||
        walletInfo!.tokenType == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;

      radioButtonSelection('POLYGON');
    } else {
      setWithdrawLimit(walletInfo!.tickerName);
    }
    if (walletUtil.usdtSpecialTokens.contains(walletInfo!.tickerName)) {
      specialTicker = "USDT";
    } else if (walletUtil.fabSpecialTokens.contains(walletInfo!.tickerName)) {
      specialTicker = "FAB";
    } else if (walletUtil.dscSpecialTokens.contains(walletInfo!.tickerName)) {
      specialTicker = "DSC";
    } else if (walletUtil.bstSpecialTokens.contains(walletInfo!.tickerName)) {
      specialTicker = "BST";
    } else if (walletUtil.exgSpecialTokens.contains(walletInfo!.tickerName)) {
      specialTicker = "EXG";
    } else {
      specialTicker = walletInfo!.tickerName;
    }

    await checkGasBalance();

    await getSingleCoinExchangeBal();

    setBusy(false);
  }

/*---------------------------------------------------
        popup to confirm withdraw coin selection
--------------------------------------------------- */

  popupToConfirmWithdrawSelection() {
    showDialog(
        context: context!,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return
              //  Platform.isIOS
              //     ? Theme(
              //         data: ThemeData.dark(),
              //         child: CupertinoAlertDialog(
              //           title: Container(
              //             margin: EdgeInsets.only(bottom: 5.0),
              //             child: Center(
              //                 child: Text(
              //               '${AppLocalizations.of(context).withdrawPopupNote}',
              //               style: headText4.copyWith(
              //                   color: primaryColor, fontWeight: FontWeight.w500),
              //             )),
              //           ),
              //           content: Container(
              //             child: Row(children: [
              //               Text(AppLocalizations.of(context).tsWalletNote,
              //                   style: headText5),
              //               Padding(
              //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
              //                 child: Text(
              //                     AppLocalizations.of(context).specialWithdrawNote,
              //                     style: headText5),
              //               ),
              //               UIHelper.verticalSpaceSmall,
              //               Text(
              //                   AppLocalizations.of(context)
              //                       .specialWithdrawFailNote,
              //                   style: headText5),
              //             ]),
              //           ),
              //           actions: <Widget>[
              //             Container(
              //               margin: EdgeInsets.all(5),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                 children: [
              //                   CupertinoButton(
              //                     padding: EdgeInsets.only(left: 5),
              //                     borderRadius:
              //                         BorderRadius.all(Radius.circular(4)),
              //                     child: Text(
              //                       AppLocalizations.of(context).close,
              //                       style: Theme.of(context)
              //                           .textTheme
              //                           .bodyText2
              //                           .copyWith(fontWeight: FontWeight.bold),
              //                     ),
              //                     onPressed: () {
              //                       Navigator.of(context).pop(true);
              //                       checkPass();
              //                     },
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ))
              // android alert
              //:
              AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(5.0),
            elevation: 5,
            backgroundColor: walletCardColor.withOpacity(0.85),
            title: Container(
              padding: const EdgeInsets.all(10.0),
              color: secondaryColor.withOpacity(0.5),
              child: Center(
                  child: Text(AppLocalizations.of(context)!.withdrawPopupNote)),
            ),
            titleTextStyle: headText5,
            contentTextStyle: const TextStyle(color: grey),
            content: Container(
              padding: const EdgeInsets.all(5.0),
              child: isWithdrawChoice
                  ? Container(
                      padding: const EdgeInsets.all(8),
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isShowTrxTsWalletBalance ||
                                        walletInfo!.tickerName == "USDT" ||
                                        walletInfo!.tickerName == "USDTX"
                                    ? Row(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: Radio(
                                                activeColor: primaryColor,
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    _groupValue = value;

                                                    radioButtonSelection(value);
                                                  });
                                                },
                                                groupValue: groupValue,
                                                value: 'TRX'),
                                          ),
                                          UIHelper.horizontalSpaceSmall,
                                          Text('TRC20', style: headText6),
                                        ],
                                      )
                                    : Row(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                            width: 20,
                                            child: Radio(
                                                //  model.groupValue == 'FAB'? fillColor: MaterialStateColor
                                                //       .resolveWith(
                                                //           (states) => Colors.blue),
                                                activeColor: primaryColor,
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    _groupValue = value;
                                                    if (value == 'FAB') {
                                                      isShowFabChainBalance =
                                                          true;
                                                      isShowTrxTsWalletBalance =
                                                          false;
                                                      if (walletInfo!
                                                              .tickerName !=
                                                          'FAB') {
                                                        walletInfo!.tokenType =
                                                            'FAB';
                                                      }
                                                      if (walletInfo!
                                                              .tickerName ==
                                                          'FAB') {
                                                        walletInfo!.tokenType =
                                                            '';
                                                      }
                                                      updateTickerForErc =
                                                          walletInfo!.tickerName;
                                                      log.i(
                                                          'chain type ${walletInfo!.tokenType}');
                                                      setWithdrawLimit(
                                                          walletInfo!
                                                              .tickerName);
                                                    } else if (value == 'TRX') {
                                                      isShowTrxTsWalletBalance =
                                                          true;
                                                      if (walletInfo!
                                                              .tickerName !=
                                                          'TRX') {
                                                        walletInfo!.tokenType =
                                                            'TRX';
                                                      }

                                                      isSpeicalTronTokenWithdraw =
                                                          true;
                                                      //  walletInfo.tokenType = 'TRX';
                                                      log.i(
                                                          'chain type ${walletInfo!.tokenType}');
                                                      setWithdrawLimit('USDTX');
                                                    }
                                                    // else if (walletInfo.tickerName == 'TRX' && !isShowTrxTsWalletBalance) {
                                                    //   await tokenListDatabaseService
                                                    //       .getByTickerName('USDTX')
                                                    //       .then((token) => withdrawLimit = double.parse(token.minWithdraw));
                                                    //   log.i('withdrawLimit $withdrawLimit');
                                                    // }
                                                    else {
                                                      isShowTrxTsWalletBalance =
                                                          false;
                                                      isShowFabChainBalance =
                                                          false;
                                                      walletInfo!.tokenType =
                                                          'ETH';
                                                      log.i(
                                                          'chain type ${walletInfo!.tokenType}');
                                                      if (walletInfo!
                                                                  .tickerName ==
                                                              'FAB' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'FABE');
                                                      } else if (walletInfo!
                                                                  .tickerName ==
                                                              'DSC' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'DSCE');
                                                      } else if (walletInfo!
                                                                  .tickerName ==
                                                              'BST' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'BSTE');
                                                      } else if (walletInfo!
                                                                  .tickerName ==
                                                              'EXG' &&
                                                          !isShowFabChainBalance) {
                                                        setWithdrawLimit(
                                                            'EXGE');
                                                      } else if (walletInfo!
                                                                  .tickerName ==
                                                              'USDTX' &&
                                                          !isShowTrxTsWalletBalance) {
                                                        setWithdrawLimit(
                                                            'USDT');
                                                      } else {
                                                        setWithdrawLimit(
                                                            walletInfo!
                                                                .tickerName);
                                                      }
                                                      setBusy(false);
                                                    }
                                                  });
                                                  radioButtonSelection(value);
                                                },
                                                groupValue: groupValue,
                                                value: 'FAB'),
                                          ),
                                          UIHelper.horizontalSpaceSmall,
                                          Text('FAB Chain', style: headText6),
                                        ],
                                      ),
                                UIHelper.horizontalSpaceMedium,
                                // erc20 radio button
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 10,
                                      width: 20,
                                      child: Radio(
                                          activeColor: primaryColor,
                                          onChanged: (dynamic value) {
                                            setState(() {
                                              _groupValue = value;
                                              //   if (value == 'FAB') {
                                              //     isShowFabChainBalance =
                                              //         true;
                                              //     isShowTrxTsWalletBalance =
                                              //         false;
                                              //     if (walletInfo
                                              //             .tickerName !=
                                              //         'FAB')
                                              //       walletInfo.tokenType =
                                              //           'FAB';
                                              //     if (walletInfo
                                              //             .tickerName ==
                                              //         'FAB')
                                              //       walletInfo.tokenType =
                                              //           '';
                                              //     updateTickerForErc =
                                              //         walletInfo.tickerName;
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     setWithdrawLimit(
                                              //         walletInfo
                                              //             .tickerName);
                                              //   } else if (value == 'TRX') {
                                              //     isShowTrxTsWalletBalance =
                                              //         true;
                                              //     if (walletInfo
                                              //             .tickerName !=
                                              //         'TRX')
                                              //       walletInfo.tokenType =
                                              //           'TRX';

                                              //     isSpeicalTronTokenWithdraw =
                                              //         true;
                                              //     //  walletInfo.tokenType = 'TRX';
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     setWithdrawLimit('USDTX');
                                              //   }
                                              //   // else if (walletInfo.tickerName == 'TRX' && !isShowTrxTsWalletBalance) {
                                              //   //   await tokenListDatabaseService
                                              //   //       .getByTickerName('USDTX')
                                              //   //       .then((token) => withdrawLimit = double.parse(token.minWithdraw));
                                              //   //   log.i('withdrawLimit $withdrawLimit');
                                              //   // }
                                              //   else {
                                              //     isShowTrxTsWalletBalance =
                                              //         false;
                                              //     isShowFabChainBalance =
                                              //         false;
                                              //     walletInfo.tokenType =
                                              //         'ETH';
                                              //     log.i(
                                              //         'chain type ${walletInfo.tokenType}');
                                              //     if (walletInfo
                                              //                 .tickerName ==
                                              //             'FAB' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'FABE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'DSC' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'DSCE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'BST' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'BSTE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'EXG' &&
                                              //         !isShowFabChainBalance) {
                                              //       setWithdrawLimit(
                                              //           'EXGE');
                                              //     } else if (walletInfo
                                              //                 .tickerName ==
                                              //             'USDTX' &&
                                              //         !isShowTrxTsWalletBalance) {
                                              //       setWithdrawLimit(
                                              //           'USDT');
                                              //     } else
                                              //       setWithdrawLimit(
                                              //           walletInfo
                                              //               .tickerName);
                                              //     setBusy(false);
                                              //   }
                                              radioButtonSelection(value);
                                            });
                                          },
                                          groupValue: groupValue,
                                          value: 'ETH'),
                                    ),
                                    UIHelper.horizontalSpaceSmall,
                                    Text('ERC20', style: headText6),
                                  ],
                                ),
                              ],
                            ),
                            // radioChoiceRow(context, isUsedInView: false),
                            UIHelper.verticalSpaceMedium,
                            // ok button to go ahead and sign and send transaction
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                    // padding: EdgeInsets.only(left: 5),
                                    // borderRadius:
                                    //     BorderRadius.all(Radius.circular(4)),
                                    child: Text(
                                      AppLocalizations.of(context)!.withdraw,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      checkPass();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }))
                  : Container(),
            ),
            // actions: [
            //   Container(
            //     child: StatefulBuilder(
            //         builder:
            //             (BuildContext context, StateSetter setState) {}),
            //   )
            // ],
          );
        });
  }

  Row radioChoiceRow(BuildContext context, {isUsedInView = true}) {
    return Row(
      mainAxisAlignment:
          isUsedInView ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        isShowTrxTsWalletBalance ||
                walletInfo!.tickerName == "USDT" ||
                walletInfo!.tickerName == "USDTX"
            ? Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 10,
                    child: Radio(
                        activeColor: primaryColor,
                        onChanged: (dynamic value) {
                          radioButtonSelection(value);
                        },
                        groupValue: groupValue,
                        value: 'TRX'),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Text('TRC20', style: headText6),
                ],
              )
            : Row(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                    width: 20,
                    child: Radio(
                        //  model.groupValue == 'FAB'? fillColor: MaterialStateColor
                        //       .resolveWith(
                        //           (states) => Colors.blue),
                        activeColor: primaryColor,
                        onChanged: (dynamic value) {
                          radioButtonSelection(value);
                        },
                        groupValue: groupValue,
                        value: 'FAB'),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Text('FAB Chain', style: headText6),
                ],
              ),
        UIHelper.horizontalSpaceMedium,
        // erc20 radio button
        Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
              width: 20,
              child: Radio(
                  activeColor: primaryColor,
                  onChanged: (dynamic value) {
                    radioButtonSelection(value);
                  },
                  groupValue: groupValue,
                  value: 'ETH'),
            ),
            UIHelper.horizontalSpaceSmall,
            Text('ERC20', style: headText6),
          ],
        ),
      ],
    );
  }

/*---------------------------------------------------
                Info about TS wallet balance
--------------------------------------------------- */
  updateIsAlert(bool value) {
    setBusy(true);
    isAlert = value;
    log.i('update isAlert $isAlert');
    setBusy(false);
  }

/*---------------------------------------------------
                Info dialog
--------------------------------------------------- */
  showInfoDialog(bool isTSWalletInfo) {
    updateIsAlert(true);

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? Theme(
                data: ThemeData.dark(),
                child: CupertinoAlertDialog(
                  title: Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Center(
                        child: Text(
                      AppLocalizations.of(context)!.note,
                      style: headText4.copyWith(
                          color: primaryColor, fontWeight: FontWeight.w500),
                    )),
                  ),
                  content: Container(
                    child: !isTSWalletInfo
                        ? Column(children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .specialExchangeBalanceNote,
                                style: headText5),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('e.g. FAB and FAB(ERC20)',
                                  style: headText5),
                            ),
                          ])
                        : Column(children: [
                            Text(AppLocalizations.of(context)!.tsWalletNote,
                                style: headText5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                  AppLocalizations.of(context)!
                                      .specialWithdrawNote,
                                  style: headText5),
                            ),
                            UIHelper.verticalSpaceSmall,
                            Text(
                                AppLocalizations.of(context)!
                                    .specialWithdrawFailNote,
                                style: headText5),
                          ]),
                  ),
                  actions: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: Text(
                              AppLocalizations.of(context)!.close,
                              textAlign: TextAlign.center,
                              style: bodyText2.copyWith(
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              updateIsAlert(false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
            : AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.all(5.0),
                elevation: 5,
                backgroundColor: walletCardColor.withOpacity(0.85),
                title: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: secondaryColor.withOpacity(0.5),
                  child: Center(child: Text(AppLocalizations.of(context)!.note)),
                ),
                titleTextStyle: headText4.copyWith(fontWeight: FontWeight.bold),
                contentTextStyle: const TextStyle(color: grey),
                content: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: !isTSWalletInfo
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Text(
                                  AppLocalizations.of(context)!
                                      .specialExchangeBalanceNote,
                                  style: headText5),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('e.g. FAB and FAB(ERC20)',
                                    style: headText5),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    updateIsAlert(false);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.close,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: red),
                                  ),
                                ),
                              )
                            ])
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                              Text(AppLocalizations.of(context)!.tsWalletNote,
                                  style: headText5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .specialWithdrawNote,
                                    style: headText5),
                              ),
                              UIHelper.verticalSpaceSmall,
                              Text(
                                  AppLocalizations.of(context)!
                                      .specialWithdrawFailNote,
                                  style: headText5),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  updateIsAlert(false);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                  style: const TextStyle(color: red),
                                ),
                              )
                            ]),
                ));
      },
    );
  }

/*---------------------------------------------------
                    Details message toggle
--------------------------------------------------- */
  showDetailsMessageToggle() {
    setBusy(true);
    isShowDetailsMessage = !isShowDetailsMessage;
    setBusy(false);
  }

/*---------------------------------------------------------------
                        Set Withdraw Limit
-------------------------------------------------------------- */

  setWithdrawLimit(String? ticker) async {
    setBusy(true);
    // if (ercChainToken.feeWithdraw != null && _groupValue == 'ETH') {
    //   token = ercChainToken;
    //   setBusy(false);
    //   return;
    // }
    // if (bnbChainToken.feeWithdraw != null && _groupValue == 'BNB') {
    //   token = bnbChainToken;
    //   setBusy(false);
    //   return;
    // }
    // if (polygonChainToken.feeWithdraw != null && _groupValue == 'POLYGON') {
    //   token = polygonChainToken;
    //   setBusy(false);
    //   return;
    // }
    // if (mainChainToken.feeWithdraw != null &&
    //     (_groupValue == 'TRX' || _groupValue == 'FAB')) {
    //   token = mainChainToken;
    //   setBusy(false);
    //   return;
    // }
    token = TokenModel();
    int? ct = 0;
    await coinService!.getCoinTypeByTickerName(ticker).then((value) {
      ct = value;
      log.i('setWithdrawLimit coin type $ct for $ticker');
    });
    await tokenListDatabaseService!.getByCointype(ct).then((res) async {
      if (res != null) {
        token = res;
        assignToken(token);
      } else {
        await coinService!
            .getSingleTokenData(ticker, coinType: ct)
            .then((resFromApi) {
          if (resFromApi != null) {
            debugPrint('token from api res ${resFromApi.toJson()}');
            token = resFromApi;
            assignToken(token);
          }
        });
      }
    });
    setBusy(false);
  }

  assignToken(TokenModel token) {
    if (_groupValue == 'ETH') ercChainToken = token;
    if (_groupValue == 'BNB') bnbChainToken = token;
    if (_groupValue == 'POLYGON') polygonChainToken = token;
    if (_groupValue == 'TRX' || _groupValue == 'FAB') {
      mainChainToken = token;
    }
  }
/*---------------------------------------------------
                      Get gas
--------------------------------------------------- */

  checkGasBalance() async {
    String address = await (sharedService!.getExgAddressFromWalletDatabase() as FutureOr<String>);
    await walletService!.gasBalance(address).then((data) {
      gasAmount = data;
      log.i('gas balance $gasAmount');
      if (gasAmount == 0) {
        sharedService!.alertDialog(
          AppLocalizations.of(context!)!.notice,
          AppLocalizations.of(context!)!.insufficientGasAmount,
        );
      }
    }).catchError((onError) => log.e(onError));
    log.w('gas amount $gasAmount');
    return gasAmount;
  }

  // Check single coin exchange balance as exchange balance is same for special tokens
  Future getSingleCoinExchangeBal() async {
    setBusy(true);
    String? tickerName = '';
    if (walletInfo!.tickerName == 'DSCE' || walletInfo!.tickerName == 'DSC') {
      tickerName = 'DSC';
      isWithdrawChoice = true;
    } else if (walletInfo!.tickerName == 'BSTE' ||
        walletInfo!.tickerName == 'BST') {
      tickerName = 'BST';
      isWithdrawChoice = true;
    } else if (walletUtil.isSpecialFab(walletInfo!.tickerName) ||
        walletInfo!.tickerName == 'FAB') {
      tickerName = 'FAB';
      isWithdrawChoice = true;
    } else if (walletInfo!.tickerName == 'EXGE' ||
        walletInfo!.tickerName == 'EXG') {
      tickerName = 'EXG';
      isWithdrawChoice = true;
    } else if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
        walletInfo!.tickerName == 'USDT') {
      tickerName = 'USDT';
      isWithdrawChoice = true;
      isShowFabChainBalance = false;
    } else if (walletInfo!.tickerName == 'MATICM') {
      tickerName = 'MATIC';
    }
    //  else if (walletInfo.tickerName == 'USDTX') {
    //   tickerName = 'USDT';
    //   isWithdrawChoice = true;
    //   isShowFabChainBalance = false;
    //   isShowTrxTsWalletBalance = true;
    // }
    else {
      tickerName = walletInfo!.tickerName;
    }
    String? fabAddress =
        await sharedService!.getFabAddressFromCoreWalletDatabase();
    await apiService!
        .getSingleWalletBalance(fabAddress, tickerName, walletInfo!.address)
        .then((res) {
      walletInfo!.inExchange = res![0].unlockedExchangeBalance;
      log.w('single coin exchange balance check ${walletInfo!.inExchange}');
    });

    if (isSubmittingTx) {
      log.i(
          'is withdraw choice and is submitting is true-- fetching ts wallet balance of group $_groupValue');
      if (_groupValue == 'ETH') {
        await getEthChainBalance();
      }
      if (_groupValue == 'TRX') {
        tickerName == 'TRX'
            ? await getTrxTsWalletBalance()
            : await getTrxUsdtTsWalletBalance();
      }
      if (_groupValue == 'BNB') await getBnbTsWalletBalance();
      if (_groupValue == 'POLYGON') await getPolygonTsWalletBalance();
      if (_groupValue == 'FAB') {
        tickerName == 'FAB'
            ? await getFabBalance()
            : await getFabChainBalance(tickerName!);
      }
    }
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        TRX TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxTsWalletBalance() async {
    setBusy(true);
    String? trxOfficialddress = coinService!.getCoinOfficalAddress('TRX');
    await apiService!.getTronTsWalletBalance(trxOfficialddress).then((res) {
      trxTsWalletBalance = res['balance'] / 1e6;
      log.e('getTrxTsWalletBalance $trxTsWalletBalance');
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        TRX USDT TS Wallet Balance
----------------------------------------------------------------------*/
  getTrxUsdtTsWalletBalance() async {
    setBusy(true);

    String? smartContractAddress = '';
    log.e(
        'getFabChainBalance tokenlist db empty, in else now-- getting data from api');
    await apiService!.getTokenListUpdates().then((tokens) {
      for (var tokenRes in tokens!) {
        if (tokenRes.tickerName == 'USDTX') {
          smartContractAddress = tokenRes.contract;
        }
      }
    });

    String trxOfficialddress = coinService!.getCoinOfficalAddress('TRX');
    await apiService!
        .getTronUsdtTsWalletBalance(trxOfficialddress, smartContractAddress)
        .then((res) {
      trxTsWalletBalance = res / 1e6;
      log.e('getTrxTsWalletBalance $trxTsWalletBalance');
    });
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        Fab Chain Balance
----------------------------------------------------------------------*/

  getFabBalance() async {
    setBusy(true);
    String? officialFabAddress = coinService!.getCoinOfficalAddress('FAB');
    await walletService!
        .coinBalanceByAddress('FAB', officialFabAddress, '')
        .then((res) {
      fabChainBalance = res['balance'];
      debugPrint('getFabBalance $fabChainBalance');
    });
    setBusy(false);
  }

  getFabChainBalance(String tickerName) async {
    setBusy(true);
    var address = sharedService!.getExgOfficialAddress()!;

    String? smartContractAddress;
    await coinService!
        .getSmartContractAddressByTickerName(tickerName)
        .then((value) => smartContractAddress = value);

    String balanceInfoABI = '70a08231';

    var body = {
      'address': trimHexPrefix(smartContractAddress!),
      'data': balanceInfoABI + fixLength(trimHexPrefix(address), 64)
    };
    var tokenBalance;
    var url = fabBaseUrl! + 'callcontract';
    debugPrint(
        'Fab_util -- address $address getFabTokenBalanceForABI balance by address url -- $url -- body $body');

    var response = await client.post(Uri.parse(url), body: body);
    var json = jsonDecode(response.body);
    var unlockBalance = json['executionResult']['output'];
    // if (unlockBalance == null || unlockBalance == '') {
    //   return 0.0;

    var unlockInt = BigInt.parse(unlockBalance, radix: 16);

    // if ((decimal != null) && (decimal > 0)) {
    //   tokenBalance = ((unlockInt) / BigInt.parse(pow(10, decimal).toString()));
    // } else {
    tokenBalance = bigNum2Double(unlockInt);
    //   // debugPrint('tokenBalance for EXG==');
    //   // debugPrint(tokenBalance);
    // }

    // }

    fabChainBalance = tokenBalance;
    debugPrint('$tickerName fab chain balance $fabChainBalance');
    setBusy(false);
  }

/*----------------------------------------------------------------------
                        ETH Chain Balance
----------------------------------------------------------------------*/
  getEthChainBalance() async {
    setBusy(true);
    String? officialAddress = '';
    officialAddress = coinService!.getCoinOfficalAddress('ETH');
    // call to get token balance
    if (walletInfo!.tickerName == 'FAB' ||
        walletUtil.isSpecialFab(walletInfo!.tickerName)) {
      updateTickerForErc = 'FABE';
    } else if (walletInfo!.tickerName == 'DSC') {
      updateTickerForErc = 'DSCE';
    } else if (walletInfo!.tickerName == 'BST') {
      updateTickerForErc = 'BSTE';
    } else if (walletInfo!.tickerName == 'EXG') {
      updateTickerForErc = 'EXGE';
    } else if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
        walletInfo!.tickerName == 'USDT') {
      updateTickerForErc = 'USDT';
    } else {
      updateTickerForErc = walletInfo!.tickerName;
    }
    // ercSmartContractAddress = await coinService
    //     .getSmartContractAddressByTickerName(updateTickerForErc);

    var fabAddress = await sharedService!.getFabAddressFromCoreWalletDatabase();
    await apiService!
        .getSingleWalletBalance(fabAddress, updateTickerForErc, officialAddress)
        .then((res) {
      ethChainBalance = res![0].balance;
    });

    log.w('ethChainBalance $ethChainBalance');
    setBusy(false);
  }

  getBnbTsWalletBalance() async {
    setBusy(true);
    String? officialAddress = '';
    officialAddress = coinService!.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService!.getFabAddressFromCoreWalletDatabase();
    String? updatedTicker = '';
    if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
        walletInfo!.tickerName == 'USDT') {
      updatedTicker = 'USDTB';
    } else if (walletInfo!.tickerName == 'FAB' ||
        walletUtil.isSpecialFab(walletInfo!.tickerName)) {
      updatedTicker = 'FABB';
    } else {
      updatedTicker = walletInfo!.tickerName;
    }
    await apiService!
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      bnbTsWalletBalance = res![0].balance;
    });

    log.w('bnbTsWalletBalance $bnbTsWalletBalance');

    setBusy(false);
  }

  getPolygonTsWalletBalance() async {
    setBusy(true);
    String? officialAddress = '';
    officialAddress = coinService!.getCoinOfficalAddress('ETH');
    var fabAddress = await sharedService!.getFabAddressFromCoreWalletDatabase();
    String? updatedTicker = '';
    if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
        walletInfo!.tickerName == 'USDT') {
      updatedTicker = 'USDTM';
    } else {
      updatedTicker = walletInfo!.tickerName;
    }
    await apiService!
        .getSingleWalletBalance(fabAddress, updatedTicker, officialAddress)
        .then((res) {
      polygonTsWalletBalance = res![0].balance;
    });

    log.w('POLYGON TsWalletBalance $polygonTsWalletBalance');

    setBusy(false);
  }
/*----------------------------------------------------------------------
                Radio button selection
----------------------------------------------------------------------*/

  radioButtonSelection(value) async {
    setBusy(true);
    debugPrint(value.toString());
    _groupValue = value;
    if (value == 'FAB') {
      isShowFabChainBalance = true;
      isShowTrxTsWalletBalance = false;
      isShowPolygonTsWalletBalance = false;
      isShowBnbTsWalletBalance = false;
      if (walletInfo!.tickerName != 'FAB' &&
          !walletUtil.isSpecialFab(walletInfo!.tickerName)) tokenType = 'FAB';
      if (walletInfo!.tickerName == 'FAB' ||
          walletUtil.isSpecialFab(walletInfo!.tickerName)) tokenType = '';
      // updateTickerForErc = walletInfo.tickerName;
      log.i('walletInfo token type ${walletInfo!.tokenType}');
      log.w('updated token type ${tokenType}');
      if (walletUtil.isSpecialFab(walletInfo!.tickerName)) {
        await setWithdrawLimit('FAB');
      } else if (walletInfo!.tickerName == 'DSCE' && isShowFabChainBalance) {
        await setWithdrawLimit('DSC');
      } else if (walletInfo!.tickerName == 'BSTE' && isShowFabChainBalance) {
        await setWithdrawLimit('BST');
      } else if (walletInfo!.tickerName == 'EXGE' && isShowFabChainBalance) {
        await setWithdrawLimit('EXG');
      } else {
        await setWithdrawLimit(walletInfo!.tickerName);
      }
    } else if (value == 'TRX') {
      isShowTrxTsWalletBalance = true;
      isShowPolygonTsWalletBalance = false;
      isShowFabChainBalance = false;
      isSpeicalTronTokenWithdraw = true;
      log.i('chain type ${walletInfo!.tokenType}');
      if (walletInfo!.tickerName == 'TRX' && isShowTrxTsWalletBalance) {
        await setWithdrawLimit('TRX');
      } else if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
          walletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDTX');
        tokenType = 'TRX';
      }
    } else if (value == 'BNB') {
      isShowBnbTsWalletBalance = true;
      isShowTrxTsWalletBalance = false;
      isShowFabChainBalance = false;
      isShowPolygonTsWalletBalance = false;
      if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
          walletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDTB');
      } else if (walletUtil.isSpecialFab(walletInfo!.tickerName) ||
          walletInfo!.tickerName == 'FAB') {
        await setWithdrawLimit('FABB');
      } else {
        await setWithdrawLimit(walletInfo!.tickerName);
      }
      tokenType = 'BNB';
    } else if (value == 'POLYGON') {
      isShowPolygonTsWalletBalance = true;
      isShowFabChainBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowTrxTsWalletBalance = false;
      if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
          walletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDTM');
      } else {
        await setWithdrawLimit(walletInfo!.tickerName);
      }
      tokenType = 'POLYGON';
    } else {
      isShowTrxTsWalletBalance = false;
      isShowFabChainBalance = false;
      isShowBnbTsWalletBalance = false;
      isShowPolygonTsWalletBalance = false;

      tokenType = 'ETH';
      log.i('chain type ${walletInfo!.tokenType}');
      if (walletInfo!.tickerName == 'FAB' ||
          walletUtil.isSpecialFab(walletInfo!.tickerName)) {
        await setWithdrawLimit('FABE');
      } else if (walletInfo!.tickerName == 'DSC' && !isShowFabChainBalance) {
        await setWithdrawLimit('DSCE');
      } else if (walletInfo!.tickerName == 'BST' && !isShowFabChainBalance) {
        await setWithdrawLimit('BSTE');
      } else if (walletInfo!.tickerName == 'EXG' && !isShowFabChainBalance) {
        await setWithdrawLimit('EXGE');
      } else if (walletUtil.isSpecialUsdt(walletInfo!.tickerName) ||
          walletInfo!.tickerName == 'USDT') {
        await setWithdrawLimit('USDT');
      } else {
        await setWithdrawLimit(walletInfo!.tickerName);
      }
      setBusy(false);
    }
  }

/*----------------------------------------------------------------------
                      Verify Wallet Password
----------------------------------------------------------------------*/
  checkPass() async {
    setBusy(true);
    isSubmittingTx = true;
    try {
      if (amountController.text.isEmpty) {
        sharedService!.sharedSimpleNotification(
            AppLocalizations.of(context!)!.amountMissing,
            subtitle: AppLocalizations.of(context!)!.pleaseEnterValidNumber);
        setBusy(false);
        return;
      }
      await checkGasBalance();
      if (gasAmount == 0.0 || gasAmount < kanbanTransFee) {
        sharedService!.alertDialog(
          AppLocalizations.of(context!)!.notice,
          AppLocalizations.of(context!)!.insufficientGasAmount,
        );
        setBusy(false);
        return;
      }

      var amount = double.tryParse(amountController.text)!;
      if (amount < double.parse(token.minWithdraw!)) {
        sharedService!.sharedSimpleNotification(
          AppLocalizations.of(context!)!.minimumAmountError,
          subtitle: AppLocalizations.of(context!)!
              .yourWithdrawMinimumAmountaIsNotSatisfied,
        );
        setBusy(false);
        return;
      }
      if (amount == null ||
          amount > walletInfo!.inExchange! ||
          amount == 0 ||
          amount.isNegative) {
        sharedService!.alertDialog(AppLocalizations.of(context!)!.invalidAmount,
            AppLocalizations.of(context!)!.pleaseEnterValidNumber,
            isWarning: false);
        setBusy(false);
        return;
      }
      await getSingleCoinExchangeBal();

      //  if (isWithdrawChoice) {
      if (groupValue == 'FAB' && amount > fabChainBalance) {
        sharedService!.alertDialog(
            AppLocalizations.of(context!)!.notice,
            AppLocalizations.of(context!)!.lowTsWalletBalanceErrorFirstPart +
                ' ' +
                fabChainBalance.toString() +
                '. ' +
                AppLocalizations.of(context!)!.lowTsWalletBalanceErrorSecondPart,
            isWarning: false);

        setBusy(false);
        return;
      }

      /// show warning like amount should be less than ts wallet balance
      /// instead of displaying the generic error

      if (groupValue == 'ETH' && amount > ethChainBalance) {
        sharedService!.alertDialog(
            AppLocalizations.of(context!)!.notice,
            AppLocalizations.of(context!)!.lowTsWalletBalanceErrorFirstPart +
                ' ' +
                ethChainBalance.toString() +
                '. ' +
                AppLocalizations.of(context!)!.lowTsWalletBalanceErrorSecondPart,
            isWarning: false);

        setBusy(false);
        return;
      }

      if (groupValue == 'TRX' && amount > trxTsWalletBalance) {
        sharedService!.alertDialog(
            AppLocalizations.of(context!)!.notice,
            AppLocalizations.of(context!)!.lowTsWalletBalanceErrorFirstPart +
                ' ' +
                trxTsWalletBalance.toString() +
                '. ' +
                AppLocalizations.of(context!)!.lowTsWalletBalanceErrorSecondPart,
            isWarning: false);
        setBusy(false);
        return;
      }

      if (groupValue == 'BNB' && amount > bnbTsWalletBalance) {
        sharedService!.alertDialog(
            AppLocalizations.of(context!)!.notice,
            AppLocalizations.of(context!)!.lowTsWalletBalanceErrorFirstPart +
                ' ' +
                bnbTsWalletBalance.toString() +
                '. ' +
                AppLocalizations.of(context!)!.lowTsWalletBalanceErrorSecondPart,
            isWarning: false);
        setBusy(false);
        return;
      }

      if (groupValue == 'POLYGON' && amount > polygonTsWalletBalance) {
        sharedService!.alertDialog(
            AppLocalizations.of(context!)!.notice,
            AppLocalizations.of(context!)!.lowTsWalletBalanceErrorFirstPart +
                ' ' +
                polygonTsWalletBalance.toString() +
                '. ' +
                AppLocalizations.of(context!)!.lowTsWalletBalanceErrorSecondPart,
            isWarning: false);
        setBusy(false);
        return;
      }
      //  }

      message = '';
      var res = await _dialogService!.showDialog(
          title: AppLocalizations.of(context!)!.enterPassword,
          description:
              AppLocalizations.of(context!)!.dialogManagerTypeSamePasswordNote,
          buttonTitle: AppLocalizations.of(context!)!.confirm);
      if (res.confirmed!) {
        String? exgAddress =
            await sharedService!.getExgAddressFromWalletDatabase();
        String mnemonic = res.returnedText!;
        Uint8List seed = walletService!.generateSeed(mnemonic);
        // if (walletInfo.tickerName == 'FAB' && ) walletInfo.tokenType = '';

        var coinName = walletInfo!.tickerName;
        String? coinAddress = '';
        if (isShowFabChainBalance &&
            coinName != 'FAB' &&
            !walletUtil.isSpecialFab(coinName)) {
          coinAddress = exgAddress;
          tokenType = 'FAB';
          log.i('coin address is exg address');
        }

        /// Ticker is FAB but fab chain balance is false then
        /// take coin address as ETH wallet address because coin is an erc20
        else if ((coinName == 'FAB' && !isShowFabChainBalance)) {
          coinAddress = await walletService!
              .getAddressFromCoreWalletDatabaseByTickerName('ETH');
          log.i('coin address is ETH address');
        }
        // i.e when user is in FABB and selects FAB withdraw
        // then token type set to empty and uses fab address
        else if ((coinName != 'FAB' && isShowFabChainBalance) &&
            walletUtil.isSpecialFab(coinName)) {
          coinAddress = await walletService!
              .getAddressFromCoreWalletDatabaseByTickerName('FAB');
          tokenType = '';
          coinName = 'FAB';
          log.i('coin address is FAB address');
        } else if (coinName == 'EXG' && !isShowFabChainBalance) {
          coinAddress = exgAddress;
          log.i('coin address is EXG address');
        } else if ((coinName == 'USDT' || walletUtil.isSpecialUsdt(coinName)) &&
            isShowTrxTsWalletBalance) {
          coinAddress = await walletService!
              .getAddressFromCoreWalletDatabaseByTickerName('TRX');
          log.i('coin address is TRX address');
          coinName = 'USDTX';
        } else {
          coinAddress = walletInfo!.address;
          log.i('coin address is its own wallet info address');
        }
        // if (!isShowFabChainBalance) {
        //   amount = BigInt.tryParse(amountController.text);
        // }
        if (coinName == 'BCH') {
          await walletService!.getBchAddressDetails(coinAddress).then(
              (addressDetails) =>
                  coinAddress = addressDetails['legacyAddress']);
        }

        var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text);
        var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text);
        // BigInt bigIntAmount = BigInt.tryParse(amountController.text);
        // log.w('Big int from amount string $bigIntAmount');
        // if (bigIntAmount == null) {
        //   bigIntAmount = BigInt.from(amount);
        //   log.w('Bigint $bigIntAmount from amount $amount ');
        // }

        if (walletInfo!.tokenType == 'TRX' ||
            walletInfo!.tickerName == 'TRX' ||
            walletInfo!.tickerName == 'USDTX' ||
            tokenType == 'TRX' ||
            coinName == 'USDTX') {
          int? kanbanGasPrice = environment['chains']['KANBAN']['gasPrice'];
          int? kanbanGasLimit = environment['chains']['KANBAN']['gasLimit'];
          await walletService!
              .withdrawTron(seed, coinName, coinAddress!, tokenType, amount,
                  kanbanPrice, kanbanGasLimit)
              .then((ret) {
            log.w(ret);
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String? txId = ret['transactionHash'];
              log.i('txid $txId');
              amountController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
              Future.delayed(const Duration(seconds: 3), () {
                getSingleCoinExchangeBal();
              });
            } else {
              serverError = ret['data'].toString();
              if (serverError == null || serverError == '') {
                var errMsg = AppLocalizations.of(context!)!.serverError;
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService!.sharedSimpleNotification(
                success && ret['transactionHash'] != null
                    ? AppLocalizations.of(context!)!.withdrawTransactionSuccessful
                    : AppLocalizations.of(context!)!.withdrawTransactionFailed,
                subtitle:
                    success ? "" : AppLocalizations.of(context!)!.networkIssue,
                isError: success ? false : true);
          }).catchError((err) {
            log.e('Withdraw catch $err');
            isShowErrorDetailsButton = true;
            isSubmittingTx = false;
            serverError = err.toString();
          });
        } else {
          // noraml withdraw function
          await walletService!
              .withdrawDo(seed, coinName, coinAddress, tokenType, amount,
                  kanbanPrice, kanbanGasLimit, isSpeicalTronTokenWithdraw)
              .then((ret) {
            log.w(ret);
            bool success = ret["success"];
            if (success && ret['transactionHash'] != null) {
              String? txId = ret['transactionHash'];
              log.i('txid $txId');
              amountController.text = '';
              serverError = '';
              isShowErrorDetailsButton = false;
              message = txId;
              Future.delayed(const Duration(seconds: 3), () {
                getSingleCoinExchangeBal();
              });
            } else {
              serverError = ret['data'];
              if (serverError == null || serverError == '') {
                var errMsg = AppLocalizations.of(context!)!.serverError;
                error(errMsg);
                isShowErrorDetailsButton = true;
                isSubmittingTx = false;
              }
            }
            sharedService!.sharedSimpleNotification(
                success && ret['transactionHash'] != null
                    ? AppLocalizations.of(context!)!.withdrawTransactionSuccessful
                    : AppLocalizations.of(context!)!.withdrawTransactionFailed,
                subtitle: success ? "" : serverError!,
                isError: success ? false : true);
          }).catchError((err) {
            log.e('Withdraw catch $err');
            isShowErrorDetailsButton = true;
            serverError = err.toString();
            isSubmittingTx = false;
          });
        }
      } else if (!res.confirmed! && res.returnedText == 'Closed') {
        debugPrint('else if close button pressed');
        isSubmittingTx = false;
      } else {
        debugPrint('else');
        if (res.returnedText != 'Closed') {
          showNotification(context);
          isSubmittingTx = false;
        }
      }
    } catch (err) {
      isShowErrorDetailsButton = true;
      serverError = err.toString();
      log.e('Withdraw catch $err');
      isSubmittingTx = false;
    }
    isSubmittingTx = false;
    setBusy(false);
  }

  showNotification(context) {
    setBusy(true);
    sharedService!.sharedSimpleNotification(
      AppLocalizations.of(context)!.passwordMismatch,
      subtitle: AppLocalizations.of(context)!.pleaseProvideTheCorrectPassword,
    );
    setBusy(false);
  }

  // update Transaction Fee

  updateTransFee() async {
    setBusy(true);
    var kanbanPrice = int.tryParse(kanbanGasPriceTextController.text)!;
    var kanbanGasLimit = int.tryParse(kanbanGasLimitTextController.text)!;

    var kanbanPriceBig = BigInt.from(kanbanPrice);
    var kanbanGasLimitBig = BigInt.from(kanbanGasLimit);
    var kanbanTransFeeDouble =
        bigNum2Double(kanbanPriceBig * kanbanGasLimitBig);
    debugPrint('Update trans fee $kanbanTransFeeDouble');

    kanbanTransFee = kanbanTransFeeDouble;
    setBusy(false);
  }

// Copy txid and display flushbar
  copyAndShowNotification(String? message) {
    sharedService!.copyAddress(context, message);
  }
}

import 'package:exchangilymobileapp/logger.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/backup_mnemonic.dart';
import 'package:exchangilymobileapp/screens/wallet_features/total_balances.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/confirm_mnemonic.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/create_password.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/import_wallet.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/choose_wallet_language.dart';
import 'package:exchangilymobileapp/screens/wallet_features/move_and_trade.dart';
import 'package:exchangilymobileapp/screens/wallet_features/receive.dart';
import 'package:exchangilymobileapp/screens/wallet_features/send.dart';
import 'package:exchangilymobileapp/screens/wallet_features/wallet_features.dart';
import 'package:exchangilymobileapp/screens/wallet_features/withdraw_to_wallet.dart';
import 'package:exchangilymobileapp/screens/wallet_setup/wallet_setup.dart';
import 'package:exchangilymobileapp/widgets/verify_mnemonic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exchangilymobileapp/screens/market/main.dart';
import 'package:exchangilymobileapp/screens/trade/main.dart';
import 'package:exchangilymobileapp/screens/wallet_features/add_gas.dart';
import 'package:exchangilymobileapp/screens/wallet_features/deposit.dart';
import 'package:exchangilymobileapp/screens/wallet_features/withdraw.dart';
import 'package:exchangilymobileapp/screens/wallet_features/smart_contract.dart';

final log = getLogger('Routes');

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    log.w(
        'generateRoute | name: ${settings.name} arguments:${settings.arguments}');
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => ChooseWalletLanguageScreen());
      case '/walletSetup':
        return MaterialPageRoute(builder: (_) => WalletSetupScreen());

      case '/importWallet':
        return MaterialPageRoute(builder: (_) => ImportWalletScreen());

      case '/confirmMnemonic':
        return MaterialPageRoute(
            builder: (_) => ConfirmMnemonictWalletScreen(mnemonic: args));

      case '/backupMnemonic':
        return MaterialPageRoute(builder: (_) => BackupMnemonicWalletScreen());

      case '/createPassword':
        return MaterialPageRoute(
            builder: (_) => CreatePasswordScreen(mnemonic: args));

      case '/totalBalance':
        return MaterialPageRoute(
            builder: (_) => TotalBalancesScreen(walletInfo: args));

      case '/walletFeatures':
        return MaterialPageRoute(
            builder: (_) => WalletFeaturesScreen(walletInfo: args));

      case '/receive':
        return MaterialPageRoute(
            builder: (_) => ReceiveWalletScreen(
                  walletInfo: args,
                ));

      case '/send':
        return MaterialPageRoute(
            builder: (_) => SendWalletScreen(
                  walletInfo: args,
                ));

      case '/moveToExchange':
        return MaterialPageRoute(builder: (_) => MoveToExchangeScreen());

      case '/withdrawToWallet':
        return MaterialPageRoute(builder: (_) => WithdrawToWalletScreen());

      case '/market':
        return MaterialPageRoute(builder: (_) => Market());

      case '/trade':
        return MaterialPageRoute(builder: (_) => Trade('EXG/USDT'));

      case '/addGas':
        return MaterialPageRoute(builder: (_) => AddGas());

      case '/smartContract':
        return MaterialPageRoute(builder: (_) => SmartContract());

      case '/deposit':
        return MaterialPageRoute(builder: (_) => Deposit(walletInfo: args));

      case '/withdraw':
        return MaterialPageRoute(builder: (_) => Withdraw(walletInfo: args));

      default:
        return _errorRoute(settings);
    }
  }

  static Route _errorRoute(settings) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text('No route defined for ${settings.name}',
              style: TextStyle(color: Colors.white)),
        ),
      );
    });
  }
}
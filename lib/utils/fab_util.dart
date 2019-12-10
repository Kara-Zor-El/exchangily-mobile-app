import 'package:http/http.dart' as http;
import '../environments/environment.dart';
import './string_util.dart';
import 'dart:convert';

final String fabBaseUrl = environment["endpoints"]["fab"];
Future getFabTransactionStatus(String txid) async {
  var url = fabBaseUrl  + 'gettransactionjson/' + txid;
  var client = new http.Client();
  var response = await client.get(url);
  return response;
}

getFabNode(root, {index = 0}) {
  var node = root.derivePath("m/44'/" + environment["CoinType"]["FAB"].toString() + "'/0'/0/" + index.toString());
  return node;
}

Future getFabBalanceByAddress(String address) async{
  var url =  fabBaseUrl + 'getbalance/' + address;
  var response = await http.get(url);
  var fabBalance = int.parse(response.body) / 1e8;
  return {'balance':fabBalance,'lockbalance': 0};
}

Future getFabTokenBalanceForABI(String balanceInfoABI, String smartContractAddress, String address) async {
  var body = {
    'address': trimHexPrefix(smartContractAddress),
    'data': balanceInfoABI + fixLength(trimHexPrefix(address), 64)
  };

  var url =  fabBaseUrl + 'callcontract';
  var response = await http.post(url, body: body);

  var json = jsonDecode(response.body);
  var unlockBalance = json['executionResult']['output'];
  // var unlockInt = int.parse(unlockBalance, radix: 16);
  var unlockInt = int.parse("0x$unlockBalance");
  var tokenBalance = unlockInt / 1e18;
  return tokenBalance;
}
Future getFabTokenBalanceByAddress(String address, String coinName) async{

  var smartContractAddress = environment["addresses"]["smartContract"][coinName];

  String balanceInfoABI = '70a08231';
  var tokenBalance = getFabTokenBalanceForABI(balanceInfoABI, smartContractAddress, address);

  balanceInfoABI = '43eb7b44';
  var tokenLockedBalance = getFabTokenBalanceForABI(balanceInfoABI, smartContractAddress, address);

  return {'balance':tokenBalance,'lockbalance': tokenLockedBalance};
}
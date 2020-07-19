import 'package:exchangilymobileapp/environments/environment_type.dart';

const String baseBlockchainGateV2Url = isProduction
    ? 'https://prod.blockchaingate.com/v2/'
    : 'https://test.blockchaingate.com/v2/';

const String baseKanbanUrl = isProduction
    ? 'https://kanbanprod.fabcoinapi.com/'
    : 'https://kanbantest.fabcoinapi.com/';

/*----------------------------------------------------------------------
                        Free Fab
----------------------------------------------------------------------*/
/// Url below not in use
const String freeFabUrl = 'https://kanbanprod.fabcoinapi.com/kanban/getairdrop';

const String getFreeFabUrl =
    baseBlockchainGateV2Url + 'airdrop/getQuestionair/';

const String postFreeFabUrl =
    baseBlockchainGateV2Url + 'airdrop/answerQuestionair/';

/*----------------------------------------------------------------------
                        USD Coin Price
----------------------------------------------------------------------*/

const String usdCoinPriceUrl =
    'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,fabcoin,tether&vs_currencies=usd';
const String coinCurrencyUsdPriceUrl =
    'https://kanbanprod.fabcoinapi.com/USDvalues';

/*----------------------------------------------------------------------
                            Next
----------------------------------------------------------------------*/

const String getAppVersionUrl = baseKanbanUrl + 'getappversion';
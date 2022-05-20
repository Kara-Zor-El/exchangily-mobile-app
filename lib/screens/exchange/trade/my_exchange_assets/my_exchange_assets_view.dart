import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/screens/exchange/trade/my_exchange_assets/my_exchange_assets_viewmodel.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:exchangilymobileapp/utils/number_util.dart';
import 'package:flutter/material.dart';

import 'package:exchangilymobileapp/widgets/shimmer_layouts/shimmer_layout.dart';
import 'package:stacked/stacked.dart';

class MyExchangeAssetsView extends StatelessWidget {
  const MyExchangeAssetsView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => MyExchangeAssetsViewModel(),
      builder: (context, MyExchangeAssetsViewModel model, _) => Container(
        child: model.isBusy
            ? const ShimmerLayout(
                layoutType: 'marketTrades',
              )
            : Column(
                children: [
                  Container(
                    color: walletCardColor,
                    padding: const EdgeInsets.all(5.0),
                    child: Row(children: <Widget>[
                      UIHelper.horizontalSpaceSmall,
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(AppLocalizations.of(context).symbol,
                              style: Theme.of(context).textTheme.subtitle2),
                        ),
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(AppLocalizations.of(context).coin,
                              style: Theme.of(context).textTheme.subtitle2),
                        ),
                      ),
                      UIHelper.horizontalSpaceSmall,
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(AppLocalizations.of(context).amount,
                              style: Theme.of(context).textTheme.subtitle2),
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Text(AppLocalizations.of(context).lockedAmount,
                              style: Theme.of(context).textTheme.subtitle2)),
                    ]),
                  ),
                  Flexible(
                    child: Container(
                      child: ListView.builder(
                          itemCount: model.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            String tickerName =
                                model.exchangeBalances[index].ticker;
                            return Container(
                              // color: grey.withAlpha(25),

                              child: Row(
                                children: [
                                  UIHelper.horizontalSpaceSmall,
                                  // Card logo container
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        //  margin: EdgeInsets.only(right: 10.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        width: 35,
                                        height: 35,
                                        child:
                                            // Image.asset(
                                            // 'assets/images/wallet-page/${tickerName.toLowerCase()}.png') ??
                                            Image.network(
                                                '${model.logoUrl}${tickerName.toLowerCase()}.png')),
                                  ),
                                  UIHelper.horizontalSpaceSmall,
                                  UIHelper.horizontalSpaceSmall,
                                  Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                            model
                                                .exchangeBalances[index].ticker,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
                                      )),
                                  UIHelper.horizontalSpaceSmall,
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          NumberUtil.decimalLimiter(
                                                  model.exchangeBalances[index]
                                                      .unlockedAmount,
                                                  decimalPrecision: 8)
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          NumberUtil.decimalLimiter(
                                                  model.exchangeBalances[index]
                                                      .lockedAmount,
                                                  decimalPrecision: 8)
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6))
                                ],
                              ),
                            );
                          }),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/models/trade/trade-model.dart';
import 'package:exchangilymobileapp/screens/exchange/trade/trade_viewmodal.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class MarketOrderDetails extends StatelessWidget {
  final List<TradeModel> marketOrderList;
  const MarketOrderDetails({Key key, this.marketOrderList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    timeFormatted(timeStamp) {
      var time = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
      return time.hour.toString() +
          ':' +
          time.minute.toString() +
          ':' +
          time.second.toString();
    }

    return Container(
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
              child: Row(
                children: <Widget>[
                  UIHelper.horizontalSpaceSmall,
                  Expanded(
                      flex: 3,
                      child: Text(AppLocalizations.of(context).price,
                          style: Theme.of(context).textTheme.subtitle2)),
                  Expanded(
                      flex: 3,
                      child: Text(AppLocalizations.of(context).quantity,
                          style: Theme.of(context).textTheme.subtitle2)),
                  Expanded(
                      flex: 2,
                      child: Text(AppLocalizations.of(context).date,
                          style: Theme.of(context).textTheme.subtitle2))
                ],
              ),
            ),
            Container(
              height: 400,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: marketOrderList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: <Widget>[
                          UIHelper.horizontalSpaceSmall,
                          Expanded(
                              flex: 3,
                              child: Text(
                                  marketOrderList[index]
                                      .price
                                      .toStringAsFixed(5),
                                  style:
                                      Theme.of(context).textTheme.headline6)),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  marketOrderList[index].amount.toString(),
                                  style:
                                      Theme.of(context).textTheme.headline6)),
                          Expanded(
                              flex: 2,
                              child: Text(
                                  timeFormatted(marketOrderList[index].time),
                                  style:
                                      Theme.of(context).textTheme.headline6)),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}

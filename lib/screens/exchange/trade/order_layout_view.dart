import 'package:exchangilymobileapp/constants/colors.dart';
import 'package:exchangilymobileapp/localizations.dart';
import 'package:exchangilymobileapp/models/trade/order-model.dart';
import 'package:exchangilymobileapp/shared/ui_helpers.dart';
import 'package:flutter/material.dart';

class OrdersLayoutView extends StatelessWidget {
  final List orderBook;
  OrdersLayoutView({Key key, this.orderBook}) : super(key: key);
  // final NavigationService navigationService = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    List<OrderModel> orderBookBuyOrders = [];
    List<OrderModel> orderBookSellOrders = [];
    if (orderBook != null) {
      orderBookBuyOrders = orderBook[0];
      orderBookSellOrders = orderBook[1];
    }
    return Container(
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            // Heading Buy Sell Orders Row
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Container(
                child: Text(AppLocalizations.of(context).buyOrders,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              Container(
                child: Text(AppLocalizations.of(context).sellOrders,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ]),
            UIHelper.horizontalSpaceSmall,
            // Buy/Sell Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Buy Orders Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: walletCardColor,
                      width: MediaQuery.of(context).size.width * 0.45,
                      padding: EdgeInsets.all(5.0),
                      // Quantity/Price headers row
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context).quantity,
                                style: TextStyle(fontSize: 9, color: grey)),
                            Text(AppLocalizations.of(context).price,
                                style: TextStyle(fontSize: 9, color: grey))
                          ]),
                    ),

                    // Buy Orders List View
                    SizedBox(
                      width: 200,
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: orderBookBuyOrders.length,
                        itemBuilder: (BuildContext context, int index) {
                          return OrderDetailsView(
                            orders: orderBookBuyOrders,
                            index: index,
                            isBuy: true,
                          );
                        },
                      ),
                    )
                  ],
                ),
                // Column Sell Orders
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        color: walletCardColor,
                        width: MediaQuery.of(context).size.width * 0.45,
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context).price,
                                  style: TextStyle(fontSize: 9, color: grey)),
                              Text(AppLocalizations.of(context).quantity,
                                  style: TextStyle(fontSize: 9, color: grey)),
                            ]),
                      ),

                      // Sell Orders List view
                      SizedBox(
                        width: 200,
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: orderBookSellOrders.length,
                          itemBuilder: (BuildContext context, int index) {
                            return OrderDetailsView(
                              orders: orderBookSellOrders,
                              index: index,
                              isBuy: false,
                            );
                          },
                        ),
                      )
                    ]),
              ],
            )
          ],
        ));
  }
}

class OrderDetailsView extends StatelessWidget {
  final int index;
  final bool isBuy;
  final List<OrderModel> orders;
  const OrderDetailsView(
      {Key key,
      @required this.orders,
      @required this.index,
      @required this.isBuy})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 2.0, right: 5.0, left: 5.0),
        padding: EdgeInsets.all(3.0),
        color: isBuy ? buyOrders : sellOrders,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Quantity Container
            Expanded(
                child: isBuy
                    ? Text('${orders[index].orderQuantity.toStringAsFixed(3)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12, color: grey))
                    : Text('${orders[index].price.toStringAsFixed(3)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 12, color: sellPrice))),
            // Price Container
            Expanded(
                child: isBuy
                    ? Text('${orders[index].price.toStringAsFixed(3)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 12, color: buyPrice))
                    : Text('${orders[index].orderQuantity.toStringAsFixed(3)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12, color: grey))),
          ],
        ));
  }
}

import "package:flutter/material.dart";

class AssetssList extends StatelessWidget {
  List<Map<String, dynamic>> assetsArray;

  AssetssList(this.assetsArray);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
                "Coin",
                style:  new TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0)
            ),
            for(var item in assetsArray)
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child:
                  Text(
                      item["coin"],
                      style:  new TextStyle(
                          color: Colors.white70,
                          fontSize: 16.0)
                  )
              )
          ],
        ),
        Column(
          children: <Widget>[

            Text(
                "Amount",
                style:  new TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0)
            ),
            for(var item in assetsArray)
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child:
                  Text(
                      item["amount"].toString(),
                      style:  new TextStyle(
                          color: Colors.white70,
                          fontSize: 16.0)
                  )
              )
          ],
        ),
        Column(
          children: <Widget>[
            Text(
                "Locked Amount",
                style:  new TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0)
            ),
            for(var item in assetsArray)

              Padding(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                  child:
                  Text(
                      item["lockedAmount"].toString(),
                      style:  new TextStyle(
                          color: Colors.white70,
                          fontSize: 16.0)
                  )
              )
          ],
        )
      ],
    );
  }

}
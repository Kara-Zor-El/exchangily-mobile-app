import '../../shared/globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateWalletScreen extends StatefulWidget {
  final List<String> mnemonic;
  const CreateWalletScreen({Key key, this.mnemonic}) : super(key: key);

  @override
  _CreateWalletScreenState createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  TextEditingController _passTextController = TextEditingController();
  TextEditingController _confirmPassTextController = TextEditingController();

  @override
  void dispose() {
    _passTextController.dispose();
    _confirmPassTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Wallet'),
        backgroundColor: globals.secondaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Enter password which contains at least 1 uppercase, 1 lowercase, 1 number and 1 special character',
              style: Theme.of(context).textTheme.headline,
              textAlign: TextAlign.left,
            ),
            TextField(
              obscureText: true,
              style: Theme.of(context).textTheme.headline,
              decoration: InputDecoration(
                labelText: 'Enter Password',
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                labelStyle: Theme.of(context).textTheme.headline,
              ),
            ),
            TextField(
              obscureText: true,
              style: TextStyle(fontSize: 15, color: Colors.white),
              decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  labelStyle: Theme.of(context).textTheme.headline),
            ),
            ButtonTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30)),
              minWidth: double.infinity,
              child: MaterialButton(
                padding: EdgeInsets.all(15),
                color: globals.primaryColor,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/balance');
                },
                child: Text(
                  'Create New Wallet',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ),
            Text(
              'Note: For Password reset you have Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
              style: Theme.of(context)
                  .textTheme
                  .headline
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'part/account_list.dart';
import 'part/asset_list.dart';
import 'part/title_bar.dart';
import 'part/transaction_list.dart';

class MainView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MainViewState();

}

class _MainViewState extends State<MainView> {

  String _selectedAddress;

  @override
  Widget build(BuildContext context) => Scaffold(

      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: Center(child: Image.asset("images/logo.png", width: 14, fit: BoxFit.fitWidth)),
          title: TitleBar()),
      body: Container(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: <Widget>[Expanded(flex: 3, child: AccountList((v) => setState(() => _selectedAddress = v))), Expanded(flex: 4, child: AssetList(_selectedAddress)), Expanded(flex: 5, child: TransactionList(_selectedAddress))], mainAxisSize: MainAxisSize.max)));

}

import 'package:bchain_app/model/block.dart';
import 'package:bchain_app/model/transaction.dart';
import 'package:bchain_app/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatefulWidget {
  final String address;

  TransactionList(this.address);

  @override
  State<StatefulWidget> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> implements WebsocketMessageListener {
  List<Transaction> _items = [];

  @override
  void initState() {
    super.initState();
    _reloadTransactions();
    Repository().registerListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    Repository().unregisterListener(this);
  }

  @override
  void didUpdateWidget(TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reloadTransactions();
  }

  _reloadTransactions() {
    if (widget.address != null && widget.address.isNotEmpty) {
      Repository().getTransactions(widget.address).then((v) {
        if (mounted) setState(() => _items = v);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.primaryTextTheme.subtitle;
    final subStyle = theme.primaryTextTheme.caption;
    return Card(
        elevation: 0,
        child: Container(
            child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Expanded(child: Text("交易记录Transactions", style: nameStyle, textAlign: TextAlign.start)), Text("最近${_items.length}条", style: subStyle)])),
          Expanded(child: ListView.builder(itemBuilder: (context, index) => TransactionListItem(_items[index], index), itemCount: _items.length))
        ], mainAxisSize: MainAxisSize.max)));
  }

  @override
  void onBlockMessage(Repository repository, Block message) {
    _reloadTransactions();
  }
}

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final int index;

  TransactionListItem(this.transaction, this.index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.primaryTextTheme.caption;
    final hashStyle = theme.textTheme.body1.copyWith(color: theme.accentColor, fontSize: 12);
    final valueStyle = theme.primaryTextTheme.caption.copyWith(color: theme.accentColor);
    final hash = transaction.TrHash ?? "";
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: index % 2 == 0 ? Colors.white.withAlpha(10) : null,
        child: Row(children: <Widget>[
          Text(_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(transaction.TimeStamp * 1000)), style: style),
          Expanded(flex: 6, child: Container(alignment: Alignment.centerLeft, child: FlatButton(child: Text(hash, style: hashStyle), onPressed: () async => await Repository().jumpPage("https://bc.cool/block/${transaction.BlkNumber}#$hash"),))),
          Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  Expanded(child: Text(_getTransactionType(transaction.TrType), style: style)),
                  Text("${_getTransactionAmountS(transaction.TrType)}${transaction.Amount} ${transaction.Symbol}", style: valueStyle)
                ]
              ))
        ]));
  }

  String _getTransactionType(int type) {
    switch (type) {
      case 0:
        return "转入";
      case 1:
        return "转出";
      default:
        return "其他";
    }
  }

  String _getTransactionAmountS(int type) {
    switch (type) {
      case 0:
        return "";
      case 1:
        return "-";
      default:
        return "";
    }
  }
}

final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

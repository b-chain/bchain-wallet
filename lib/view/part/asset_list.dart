import 'package:bchain_app/model/asset.dart';
import 'package:bchain_app/model/block.dart';
import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetList extends StatefulWidget {
  final String address;

  AssetList(this.address);

  @override
  State<StatefulWidget> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> implements WebsocketMessageListener {
  final Asset _bcAsset = Asset("0xb78f12Cb3924607A8BC6a66799e159E3459097e9", "BC", "", "8", "", "");
  String _address;
  List _assets = [];

  @override
  void initState() {
    super.initState();
    _address = widget.address;
    _resetAssetsMap();
    Repository().registerListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    Repository().unregisterListener(this);
  }

  @override
  void didUpdateWidget(AssetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetAddress();
  }

  _resetAssetsMap() {
    _assets.clear();
    _addAsset(_bcAsset);
  }

  _addAsset(Asset asset) {
    final contract = asset.ConAddr;
    final last = _assets.isEmpty ? null : _assets.last;
    if (last == null || (last is Asset) && last.ConAddr != contract) _assets.add([contract, asset.BtCreator]);
    _assets.add(asset);
  }

  _resetAddress() {
    if (_address != widget.address) _reloadAsset();
  }

  _reloadAsset() {
    final address = widget.address;
    final repo = Repository();
    repo.getAddressCreatedContract(address).then((contracts) => repo.getAssets().then((list) {
          _resetAssetsMap();
          list.forEach((a) {
            contracts.remove(a.ConAddr);
            _addAsset(a);
          });
          _assets.insertAll(0, contracts.map((s) => [s, address]));
          if (mounted) setState(() => _address = address);
        }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.primaryTextTheme.subtitle;
    final captionStyle = theme.primaryTextTheme.caption;
    final actionStyle = captionStyle.copyWith(color: theme.accentColor);
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Card(
          elevation: 0,
          child: Padding(
              padding: EdgeInsets.only(left: 16, right: 10, top: 14, bottom: 14),
              child: Row(children: <Widget>[
                Expanded(child: Text("资产Assets", style: nameStyle)),
                FlatButton(
                    child: Text("索引代币合约", style: actionStyle),
                    onPressed: () async {
                      final result = await showInputDialog(context, title: "索引代币合约地址", hint: "输入或粘贴代币合约地址", label: "索引的代币合约将在资产中展示。");
                      if (result != null && result.isNotEmpty) {
                        await Repository().addContractIndex(result).then((_) => showInfoMessageDialog(context, "已开始索引合约")).catchError((e) => showErrorMessageDialog(context, e));
                      }
                    }),
                FlatButton(
                    child: Text("创建代币合约", style: actionStyle),
                    onPressed: () async {
                      final result = await showCreateTokenContractDialog(context, _address).catchError((e) => showErrorMessageDialog(context, e));
                      if (result != null && result.isNotEmpty) await showInfoMessageDialog(context, result);
                    })
              ]))),
      Expanded(
          child: _address == null || _address.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemBuilder: (context, index) {
                    final item = _assets[index];
                    if (item is Asset) {
                      return AssetListItem(
                        widget.address,
                        item,
                        isBcToken: item == _bcAsset,
                      );
                    } else {
                      final isCreator = _address == item[1];
                      final ca = item[0] ?? "";
                      return Row(children: <Widget>[
                        SizedBox(width: 10),
                        Text("资产合约", style: captionStyle),
                        Expanded(
                            child: Container(
                                alignment: Alignment.centerLeft,
                                child:
                                    FlatButton(child: Text(ca, style: actionStyle), onPressed: ca.isEmpty ? null : () => Clipboard.setData(ClipboardData(text: ca))))),
                        isCreator
                            ? FlatButton(
                                child: Text("创建代币", style: actionStyle),
                                onPressed: () async {
                                  final result = await showCreateTokenDialog(context, _address, item[0]);
                                  if (result != null && result.isNotEmpty) {
                                    showInfoMessageDialog(context, "已发布代币，交易hash $result，正在等待区块确认。");
                                  }
                                })
                            : SizedBox()
                      ]);
                    }
                  },
                  itemCount: _assets.length))
    ]));
  }

  @override
  void onBlockMessage(Repository repository, Block message) {
    _reloadAsset();
  }
}

class AssetListItem extends StatefulWidget {
  final String address;
  final String logo;
  final Asset asset;
  final bool isBcToken;

  AssetListItem(this.address, this.asset, {this.logo = "images/logo.png", this.isBcToken = false});

  @override
  State<StatefulWidget> createState() => _AssetListItemState();
}

class _AssetListItemState extends State<AssetListItem> {
  String _balance = "0";
  Asset _asset;

  @override
  void initState() {
    super.initState();
    _refreshBalance();
  }

  @override
  void didUpdateWidget(AssetListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshBalance();
  }

  _refreshBalance() {
    _asset = widget.asset;
    Repository().getBalance(widget.address, _asset.ConSymbol, _asset.ConAddr).then((b) {
      if (mounted) setState(() => _balance = b);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.primaryTextTheme.title;
    final subStyle = theme.primaryTextTheme.subhead;
    final captionStyle = theme.primaryTextTheme.caption.copyWith(fontSize: 11);
    final token = _asset == null ? "" : _asset.ConSymbol;
    final hasBalance = _balance != '0';
    return Card(
        elevation: 0,
        child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
            alignment: Alignment.centerLeft,
            child: Row(children: <Widget>[
              Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    widget.logo,
                    width: 30,
                  )),
              Expanded(child: Text(token, style: nameStyle)),
              Text("可用余额", style: captionStyle),
              SizedBox(width: 10),
              Text(_balance, style: subStyle),
              hasBalance
                  ? FlatButton(
                      child: Text("转账", style: captionStyle.copyWith(color: theme.accentColor)),
                      onPressed: () async {
                        final hash = await showCreateTransactionDialog(context, widget.address, _asset.ConAddr, token);
                        if (hash != null && hash.isNotEmpty) showConfirmDialog(context, "提示", "交易已发送，等待区块确认中\n\n$hash", cancelText: null);
                      })
                  : SizedBox(width: 20),
            ])));
  }
}

import 'dart:ui';

import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountList extends StatefulWidget {
  final ValueChanged<String> selectedChanged;

  AccountList(this.selectedChanged);

  @override
  State<StatefulWidget> createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {

  List<String> _accountAddresses = [];
  String _selectedAddress;
  ScrollController _listController;

  _selectAddress(String value) {
    if (_selectedAddress != value) {
      setState(() => _selectedAddress = value);
      widget.selectedChanged(value);
    }
  }

  @override
  void initState() {
    super.initState();
    _listController = ScrollController();
    _reloadAccounts();
  }

  _reloadAccounts() {
    final repo = Repository();
    changeSelect() => setState(() {
      _selectedAddress = _accountAddresses.isEmpty ? null : _accountAddresses.first;
      widget.selectedChanged(_selectedAddress);
    });
    repo.getAccountAddresses().then((accounts) async {
      _accountAddresses = accounts;
      while (_accountAddresses.isEmpty) {
        final password = await showCreatePasswordDialog(context, title: "创建新账号，请输入密码");
        if (password != null && password.isNotEmpty) {
          final address = await repo.createAccountAddress(password);
          if (address != null && address.isNotEmpty) {
            _accountAddresses.add(address);
            changeSelect();
          }
        }
      }
      changeSelect();
      if (mounted) setState(() { });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _listController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.primaryTextTheme.subtitle;
    final captionStyle = theme.textTheme.caption.copyWith(color: theme.accentColor);
    final buttonStyle = theme.primaryTextTheme.caption;
    return Card(
        elevation: 0,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(children: <Widget>[
              Row(children: <Widget>[
                Expanded(child: Text("账户Accounts", style: nameStyle)),
                FlatButton.icon(
                    onPressed: () async {
                      final address = await showImportKeystoreDialog(context);
                      if (address != null) {
                        if (address.isNotEmpty) setState(() { _accountAddresses.add(address); }); else showConfirmDialog(context, "错误", "导入keystore失败。", cancelText: null);
                      }
                    },
                    icon: Icon(Icons.input, color: theme.accentColor, size: 12),
                    label: Text("导入账户", style: captionStyle)),
                CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(20),
                    minSize: 0,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(children: <Widget>[Icon(Icons.add, color: Colors.white, size: 12), SizedBox(width: 6), Text("新建账户", style: buttonStyle)]),
                    onPressed: () async {
                      final password = await showCreatePasswordDialog(context, title: "新建账户");
                      if (password != null) {
                        final address = await Repository().createAccountAddress(password);
                        setState(() {
                          _accountAddresses.remove(address);
                          _accountAddresses.add(address);
                          _listController.animateTo(_accountAddresses.length * 100.0, duration: Duration(milliseconds: 100), curve: Curves.linear);
                        });
                      }
                    })
              ], mainAxisSize: MainAxisSize.max),
              Expanded(
                  child: ListView.builder(
                    controller: _listController,
                      itemBuilder: (context, index) {
                        final address = _accountAddresses[index];
                        final selected = address == _selectedAddress;
                        final widget = AccountListItem(_accountAddresses[index], index);
                        return selected ? widget : Opacity(opacity: 0.2, child: InkWell(child: widget, onTap: () => _selectAddress(address)));
                      },
                      itemCount: _accountAddresses.length))
            ], mainAxisSize: MainAxisSize.max)));
  }
}

const List<LinearGradient> _gradients = [
  LinearGradient(colors: [Color(0xFF159B24), Color(0xFF46CB6C)]),
  LinearGradient(colors: [Color(0xFF97E3FF), Color(0xFF4EB2EA)]),
  LinearGradient(colors: [Color(0xFF97B1FF), Color(0xFF4E7DEA)]),
  LinearGradient(colors: [Color(0xFFBC97FF), Color(0xFF7E4EEA)])
];

class AccountListItem extends StatefulWidget {
  final String address;
  final int index;


  AccountListItem(this.address, this.index);

  @override
  State<StatefulWidget> createState() => _AccountListItemState();
}

class _AccountListItemState extends State<AccountListItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.primaryTextTheme.title;
    final subStyle = theme.primaryTextTheme.caption;
    final address = widget.address;
    return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10), gradient: _gradients[widget.index % _gradients.length]),
        alignment: Alignment.centerLeft,
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Text("Wallet-${widget.index}", style: nameStyle)),
            ButtonBar(children: <Widget>[
              InkWell(
                  child: Icon(Icons.lock_open, color: Colors.white),
                  onTap: () async {
                    final List<String> ps = await showModifyPasswordDialog(context);
                    if (ps != null && ps.isNotEmpty) {
                      await Repository().modifyAccountAddressPassword(address, ps[0], ps[1])
                          .then((e) => showConfirmDialog(context, "提示", "修改密码成功。", cancelText: null).then(((_) => "")))
                          .catchError((e) => showConfirmDialog(context, "错误", "原密码不正确。", cancelText: null).then(((_) => "")));
                    }
                  }),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                  child: Icon(Icons.photo_size_select_large, color: Colors.white),
                  onTap: () async {
                    final password = await showInputDialog(context, title: "导出Keystore", label: "输入账户密码", obscureText: true, pasteButton: false);
                    if (password != null && password.isNotEmpty) {
                      final result = await Repository().exportKeystore(address, password);
                      await showInputDialog(context, title: "Keystore内容", content: result, pasteButton: false);
                    }
                  })),
              InkWell(
                  child: Icon(Icons.image_aspect_ratio, color: Colors.white),
                  onTap: () async {
                    await showQrCodeDialog(context, "收款地址", address);
                  })
            ])
          ]),
          SizedBox(height: 20),
          Text(widget.address, style: subStyle)
        ], mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start));
  }
}

import 'package:bchain_app/view/part/create_password.dart';
import 'package:bchain_app/view/part/create_token.dart';
import 'package:bchain_app/view/part/create_token_contract.dart';
import 'package:bchain_app/view/part/create_transaction.dart';
import 'package:bchain_app/view/part/import_keystore.dart';
import 'package:bchain_app/view/part/input_content.dart';
import 'package:bchain_app/view/part/modify_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

Dialog _createDialog(BuildContext context, String title, Widget content, {double width = 310, Widget action}) {
  final theme = Theme.of(context);
  final titleStyle = theme.primaryTextTheme.subhead.copyWith(color: theme.accentColor);
  final w = action == null ? EdgeInsets.fromLTRB(20, 20, 20, 10) : EdgeInsets.symmetric(vertical: 20, horizontal: 20);
  return Dialog(
      shape: Border.all(width: 0),
      child: Container(
          width: width,
          color: theme.canvasColor,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Container(
                padding: EdgeInsets.all(6),
                color: Colors.black.withAlpha(200),
                child: Row(children: <Widget>[
                  SizedBox(width: 20),
                  Expanded(child: Text(title, style: titleStyle)),
                  IconButton(icon: Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))
                ])),
            Container(alignment: Alignment.centerLeft, child: content, margin: w),
            action == null ? SizedBox() : Container(alignment: Alignment.centerLeft, child: action, margin: EdgeInsets.only(left: 20, right: 20, bottom: 5)),
          ])));
}

InputDecoration createInputDecoration({String hint, Widget suffix, Widget prefix}) {
  final border = OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF979797), width: 0.5));
  final decoration = InputDecoration(
      hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      suffix: suffix,
      prefix: prefix,
      filled: true,
      hintText: hint,
      enabledBorder: border,
      focusedBorder: border,
      border: border);
  return decoration;
}

Future<bool> showConfirmDialog(BuildContext context, String title, String message, {String confirmText = "确定", String cancelText = "取消"}) async {
  final theme = Theme.of(context);
  final buttonStyle = theme.primaryTextTheme.body1;
  final messageStyle = theme.primaryTextTheme.body1.copyWith(color: Colors.white.withAlpha(200));
  final actions = <Widget>[
    Expanded(child: FlatButton(color: Color(0xFF7D7D7D), child: Text(cancelText ?? "", style: buttonStyle), onPressed: () => Navigator.pop(context, false))),
    SizedBox(width: 20),
    Expanded(child: FlatButton(color: theme.accentColor, child: Text(confirmText ?? "", style: buttonStyle), onPressed: () => Navigator.pop(context, true))),
  ];
  if (confirmText == null || confirmText.isEmpty)
    actions.removeRange(1, actions.length);
  else if (cancelText == null || cancelText.isEmpty) actions.removeRange(0, actions.length - 1);
  final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => _createDialog(
          context, title, Container(alignment: Alignment.centerLeft, child: Text(message, style: messageStyle), margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20)),
          action: Row(children: actions, mainAxisSize: MainAxisSize.max)));
  return result ?? false;
}

Future showErrorMessageDialog(BuildContext context, e) async => await showConfirmDialog(context, "错误", e.toString(), cancelText: null);

Future showInfoMessageDialog(BuildContext context, e) async => await showConfirmDialog(context, "信息", e.toString(), cancelText: null);

Future<String> showImportKeystoreDialog(BuildContext context) async => await showDialog<String>(
    context: context, builder: (BuildContext context) => _createDialog(context, "导入Keystore", ImportKeystore(), width: 400));

Future<String> showCreateTokenContractDialog(BuildContext context, String address) async => await showDialog<String>(
    context: context, builder: (BuildContext context) => _createDialog(context, "创建标准代币合约", CreateTokenContract(address), width: 400));

Future<String> showCreateTransactionDialog(BuildContext context, String address, String contract, String token, {String title = "转账", String confirmText = "确定"}) async => await showDialog<String>(
    context: context, builder: (BuildContext context) => _createDialog(context, title, CreateTransaction(address, contract, token), width: 400));

Future<String> showCreateTokenDialog(BuildContext context, String address, String contract, {String title = "创建代币", String confirmText = "确定"}) async =>
    await showDialog<String>(context: context, builder: (BuildContext context) => _createDialog(context, title, CreateToken(address, contract), width: 400));

Future<List<String>> showModifyPasswordDialog(BuildContext context, {String title = "修改密码", String confirmText = "确定"}) async =>
    await showDialog<List<String>>(context: context, builder: (BuildContext context) => _createDialog(context, title, ModifyPassword((old, n) => Navigator.pop(context, [old, n]))));

Future<String> showCreatePasswordDialog(BuildContext context, {String title = "创建密码", String confirmText = "确定"}) async =>
    await showDialog<String>(context: context, builder: (BuildContext context) => _createDialog(context, title, CreatePassword((password) => Navigator.pop(context, password))));

Future<void> showQrCodeDialog(BuildContext context, String title, String content) async {
  final theme = Theme.of(context);
  final titleStyle = theme.primaryTextTheme.subhead.copyWith(color: theme.accentColor);
  final bodyStyle = theme.textTheme.caption.copyWith(color: Colors.white);
  final widget = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              QrImage(
                backgroundColor: Colors.white,
                data: content,
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 20),
              Text(content, style: bodyStyle)
            ],
            mainAxisSize: MainAxisSize.min)),
    Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        alignment: Alignment.center,
        child: OutlineButton(color: theme.accentColor, child: Text("复制", style: titleStyle), onPressed: () => Clipboard.setData(ClipboardData(text: content))))
  ]);
  await showDialog<String>(context: context, builder: (BuildContext context) => _createDialog(context, title, widget, width: 360));
}

Future<String> showInputDialog(BuildContext context, {
  String title = "输入内容", String label, String hint, String confirmText = "确定",
  String content, String cancelText, int minLine, int maxLine, bool obscureText = false, bool pasteButton = true}) async {
  return await showDialog<String>(
      context: context, builder: (BuildContext context) => _createDialog(context, title, InputContent(content: content, label: label, hint: hint, confirmText: confirmText, cancelText: cancelText, minLines: minLine, maxLines: maxLine, obscureText: obscureText, pasteButton: pasteButton), width: 360));
}

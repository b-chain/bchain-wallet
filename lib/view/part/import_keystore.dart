import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImportKeystore extends StatefulWidget {

  ImportKeystore();

  @override
  State<StatefulWidget> createState() => _ImportKeystoreState();
}

class _ImportKeystoreState extends State<ImportKeystore> {

  String _password;
  String _keystore;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.primaryTextTheme.body1;
    final labelStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white.withAlpha(100));
    final passwordStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text("输入Keystore", style: labelStyle),
      SizedBox(height: 10),
      TextField(
        controller: _controller,
          onChanged: (value) => setState(() => _keystore = value), decoration: createInputDecoration(hint: "输入或者粘贴Keystore内容",
          suffix: InkWell(
              child: Icon(Icons.content_paste, size: 10, color: Colors.white),
              onTap: () async {
                final text = await Clipboard.getData("text/plain");
                _keystore = text.text;
                _controller.value = TextEditingValue(text: text.text);
              })), style: passwordStyle, minLines: 10, maxLines: 1000),
      SizedBox(height: 20),
      Text("密码", style: labelStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _password = value), decoration: createInputDecoration(), style: passwordStyle, obscureText: true),
      SizedBox(height: 16),
      Row(
        children: <Widget>[
          Expanded(
              child: FlatButton(
                  color: theme.accentColor, disabledColor: Color(0xFF7D7D7D), child: Text("确定", style: buttonStyle), onPressed: _hasValidInput() ? () async {
                  final result = await Repository().importKeystore(_keystore, _password).catchError((e) => "");
                  print(result);
                  Navigator.maybePop(context, result);
              } : null))
        ],
        mainAxisSize: MainAxisSize.max,
      )
    ]);
  }

  bool _hasValidInput() => _password != null && _password.isNotEmpty && _keystore != null && _keystore.isNotEmpty;

}

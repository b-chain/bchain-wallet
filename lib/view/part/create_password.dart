import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class CreatePassword extends StatefulWidget {
  final ValueChanged valueCallback;

  CreatePassword(this.valueCallback);

  @override
  State<StatefulWidget> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  String _password, _confirmPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.primaryTextTheme.body1;
    final captionStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white.withAlpha(100));
    final passwordStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text("设置账户密码", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _password = value), decoration: createInputDecoration(), obscureText: true, style: passwordStyle),
      SizedBox(height: 20),
      Text("确认密码", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _confirmPassword = value), decoration: createInputDecoration(), obscureText: true, style: passwordStyle),
      SizedBox(height: 20),
      Row(children: <Widget>[
        Expanded(
            child: FlatButton(
                color: theme.accentColor, disabledColor: Color(0xFF7D7D7D), child: Text("确定", style: buttonStyle), onPressed: _hasInputPassword() ? () => widget.valueCallback(_password) : null))
      ], mainAxisSize: MainAxisSize.max)
    ]);
  }

  bool _hasInputPassword() => _password != null && _password.isNotEmpty && _confirmPassword == _password;
}

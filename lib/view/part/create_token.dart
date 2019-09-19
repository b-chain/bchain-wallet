import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateToken extends StatefulWidget {

  final String address, contractAddress;

  CreateToken(this.address, this.contractAddress);

  @override
  State<StatefulWidget> createState() => _CreateTokenState();
}

class _CreateTokenState extends State<CreateToken> {

  String _password;
  String _totalValue, _decimalValue, _token;
  double _minFee = 0.1, _maxFee = 1, _fee;

  @override
  void initState() {
    super.initState();
    _fee = _minFee;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.primaryTextTheme.body1;
    final captionStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white.withAlpha(100));
    final passwordStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text("代币名称", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _token = value), decoration: createInputDecoration(hint: "输入币种名称，例如 BTC"), style: passwordStyle),
      SizedBox(height: 20),
      Text("发行总量", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _totalValue = value), decoration: createInputDecoration(hint: "输入发行总量，例如 100000000"), style: passwordStyle),
      SizedBox(height: 20),
      Text("代币精度", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _decimalValue = value), decoration: createInputDecoration(hint: "输入代币精度，例如 8"), style: passwordStyle),
      Text("手续费", style: captionStyle),
      Slider(value: _fee, onChanged: (v) => setState(() => _fee = v), min: _minFee, max: _maxFee),
      Row(children: <Widget>[
        Text("$_minFee BC", style: captionStyle),
        Expanded(child: Text("已选择 $_fee BC", textAlign: TextAlign.center, style: captionStyle.copyWith(color: theme.accentColor))),
        Text("$_maxFee BC", style: captionStyle)
      ]),
      SizedBox(height: 20),
      Text("密码", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _password = value), decoration: createInputDecoration(), style: passwordStyle, obscureText: true),
      SizedBox(height: 16),
      Row(
        children: <Widget>[
          Expanded(
              child: FlatButton(
                  color: theme.accentColor, disabledColor: Color(0xFF7D7D7D), child: Text("确定", style: buttonStyle), onPressed: _hasValidInput() ? () async {
                    final result = await Repository().createToken(widget.address, _password, _fee, _token, _decimalValue, _totalValue, widget.contractAddress).catchError((e) => showErrorMessageDialog(context, e));
                    if (result != null && result.isNotEmpty) Navigator.pop(context, result);
              } : null))
        ],
        mainAxisSize: MainAxisSize.max,
      )
    ]);
  }

  bool _hasValidInput() => _password != null && _password.isNotEmpty
      && _totalValue != null && _totalValue.isNotEmpty
      && _decimalValue != null && _decimalValue.isNotEmpty
      && _token != null && _token.isNotEmpty;
}

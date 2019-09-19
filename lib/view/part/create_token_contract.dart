import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateTokenContract extends StatefulWidget {

  final String address;

  CreateTokenContract(this.address);

  @override
  State<StatefulWidget> createState() => _CreateTokenContractState();
}

class _CreateTokenContractState extends State<CreateTokenContract> {

  String _password;
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
    final bodyStyle = theme.primaryTextTheme.body1;
    final passwordStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text("发布代币合约后，可以自由在合约下创建自己的代币。", style: bodyStyle),
      SizedBox(height: 20),
      Text("手续费", style: captionStyle),
      Slider(min: _minFee, max: _maxFee, value: _fee, onChanged: (v) => setState(() => _fee = double.parse(v.toStringAsFixed(1)))),
      Row(children: <Widget>[
        Text("$_minFee BC", style: captionStyle),
        Expanded(child: Text("已选择 $_fee BC", textAlign: TextAlign.center, style: captionStyle.copyWith(color: theme.accentColor))),
        Text("$_maxFee BC", style: captionStyle)
      ], mainAxisSize: MainAxisSize.max),
      SizedBox(height: 20),
      Text("密码", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _password = value), decoration: createInputDecoration(hint: "输入交易密码"), style: passwordStyle, obscureText: true),
      SizedBox(height: 16),
      Row(
        children: <Widget>[
          Expanded(
              child: FlatButton(
                  color: theme.accentColor, disabledColor: Color(0xFF7D7D7D), child: Text("确定", style: buttonStyle), onPressed: _hasValidInput() ? () async {
                    try {
                      final hash = await Repository().createBigTokenContract(widget.address, _password, _fee);
                      Navigator.pop(context, hash);
                    } catch (e) {
                      showConfirmDialog(context, "错误", "参数不正确或密码错误。\n${e.toString()}", cancelText: null);
                    }
              } : null))
        ],
        mainAxisSize: MainAxisSize.max,
      )
    ]);
  }

  bool _hasValidInput() => _password != null && _password.isNotEmpty;

}

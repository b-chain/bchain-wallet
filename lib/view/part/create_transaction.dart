import 'package:bchain_app/repository.dart';
import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTransaction extends StatefulWidget {

  final String address;
  final String contract;
  final String token;

  CreateTransaction(this.address, this.contract, this.token);

  @override
  State<StatefulWidget> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  String _password;
  String _receiveAddress;
  String _token;
  String _value;
  String _summary;
  double _minFee = 0.1, _maxFee = 1, _fee;
  final _assetInputController = TextEditingController();
  final _addressInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fee = _minFee;
    _resetToken();
  }

  @override
  void didUpdateWidget(CreateTransaction oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetToken();
  }

  _resetToken() {
    _token = widget.token;
    _assetInputController.value = TextEditingValue(text: _token);
  }

  @override
  void dispose() {
    super.dispose();
    _assetInputController.dispose();
    _addressInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = theme.primaryTextTheme.body1;
    final captionStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white.withAlpha(100));
    final passwordStyle = theme.primaryTextTheme.subtitle.copyWith(color: Colors.white);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Text("收款地址", style: captionStyle),
      SizedBox(height: 10),
      TextField(
          controller: _addressInputController,
          onChanged: (value) => setState(() => _receiveAddress = value),
          decoration: createInputDecoration(
            hint: "输入或点击右侧按钮粘贴收款地址",
              suffix: InkWell(
                  child: Icon(Icons.content_paste, size: 10, color: Colors.white),
                  onTap: () async {
                    final text = await Clipboard.getData("text/plain");
                    _receiveAddress = text.text;
                    _addressInputController.value = TextEditingValue(text: _receiveAddress);
                  })),
          style: passwordStyle),
      Container(margin: EdgeInsets.only(top: 20, bottom: 10), child: Text("合约地址", style: captionStyle)),
      Text(widget.contract, style: buttonStyle),
      SizedBox(height: 20),
      Row(children: <Widget>[
        Expanded(
            child: Column(children: <Widget>[
          Text("资产", style: captionStyle),
          SizedBox(height: 10),
          TextField(
              controller: _assetInputController,
              onChanged: (value) => setState(() => _token = value),
              decoration: createInputDecoration(suffix: Icon(Icons.unfold_more, size: 10, color: Colors.white)),
              style: passwordStyle,
              enabled: false),
        ], mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start)),
        SizedBox(width: 20),
        Expanded(
            child: Column(children: <Widget>[
          Text("金额", style: captionStyle),
          SizedBox(height: 10),
          TextField(onChanged: (value) => setState(() => _value = value), decoration: createInputDecoration(hint: "输入转账金额"), style: passwordStyle),
        ], mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start)),
      ], mainAxisSize: MainAxisSize.max),
      SizedBox(height: 20),
      Text("备注", style: captionStyle),
      SizedBox(height: 10),
      TextField(onChanged: (value) => setState(() => _summary = value), decoration: createInputDecoration(hint: "可选"), style: passwordStyle),
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
                    final hash = await Repository().sendTransaction(widget.address, _password, _fee, _receiveAddress, _value, _token, _summary, widget.contract).catchError((e) {
                        showConfirmDialog(context, "错误", "转账失败", cancelText: null);
                    });
                    if (hash != null && hash.isNotEmpty) Navigator.maybePop(context, hash);
              } : null))
        ],
        mainAxisSize: MainAxisSize.max,
      )
    ]);
  }

  bool _hasValidInput() =>
      _password != null && _password.isNotEmpty && _value != null && _value.isNotEmpty && _token != null && _token.isNotEmpty && _receiveAddress != null && _receiveAddress.isNotEmpty;
}

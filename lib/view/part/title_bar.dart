import 'package:bchain_app/model/block.dart';
import 'package:bchain_app/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TitleBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TitleBarState();
}

class _TitleBarState extends State<TitleBar> implements WebsocketMessageListener {

  int _currentBlockNumber = 0, _topBlockNumber = 1;

  @override
  void initState() {
    super.initState();
    final repo = Repository();
    repo.getChainInfo().then((v) { if (mounted) _resetInfo(v); });
    repo.registerListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    Repository().unregisterListener(this);
  }

  _resetInfo(Block b) {
    if (b.CurBlock != _currentBlockNumber || b.TargetBlock != _topBlockNumber) {
      setState(() {
        _currentBlockNumber = b.CurBlock;
        if (b.TargetBlock > _topBlockNumber) _topBlockNumber = b.TargetBlock;
      });
    }
  }

  @override
  void onBlockMessage(Repository repository, Block message) {
    if (mounted) _resetInfo(message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.primaryTextTheme.caption.copyWith(color: theme.accentColor);
    final double value = _currentBlockNumber / _topBlockNumber.toDouble();
    return Row(children: <Widget>[
      Expanded(child: SizedBox()),
      Text("BChain", style: titleStyle),
      Container(child: Text(_currentBlockNumber != _topBlockNumber ? "区块同步中..." : "区块同步完成", style: titleStyle), margin: EdgeInsets.symmetric(horizontal: 20)),
      Text("当前下载：$_currentBlockNumber/$_topBlockNumber", style: titleStyle),
      Container(margin: EdgeInsets.symmetric(horizontal: 10), height: 2, width: 200, child: LinearProgressIndicator(value: value)),
      Text("${(value * 100).toStringAsFixed(2)}%", style: titleStyle),
      Expanded(child: SizedBox()),
      FlatButton(child: Text("区块浏览", style: titleStyle), onPressed: () async => await Repository().jumpPage("https://bc.cool")),
      /*
      SizedBox(width: 20),
      _createCircleButton(theme, Icons.expand_more, () {}),
      SizedBox(width: 10),
      _createCircleButton(theme, Icons.close, () => SystemNavigator.pop()),
       */
      SizedBox(width: 10)
    ], mainAxisSize: MainAxisSize.max);
  }

  Widget _createCircleButton(ThemeData theme, IconData icon, VoidCallback onPressed) => Container(
      padding: EdgeInsets.all(4),
      child: InkWell(child: Icon(icon, color: Colors.white, size: 12), onTap: onPressed),
      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.accentColor.withAlpha(40)));
}

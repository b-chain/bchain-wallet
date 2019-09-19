import 'dart:async';

import 'package:bchain_app/view/main_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SplashViewState();

}

class _SplashViewState extends State<SplashView> {

  double _progressValue = 0.1;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) => setState(() {
      _progressValue += 0.1;
      if (_progressValue >= 1) {
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainView()));
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.primaryTextTheme.subhead.copyWith(color: theme.accentColor);
    return Scaffold(
        body: Center(child: Image.asset("images/logo.png", width: 60, fit: BoxFit.fitWidth)),
        bottomNavigationBar: Column(children: <Widget>[
          Text("BChain...", style: textStyle),
          SizedBox(height: 10),
          LinearProgressIndicator(value: _progressValue)],
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center),
      );
  }

}

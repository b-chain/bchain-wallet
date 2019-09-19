import 'package:bchain_app/view/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputContent extends StatefulWidget {
  final String content;
  final String confirmText;
  final String cancelText;
  final String label, hint;
  final bool obscureText, pasteButton, copyButton, disableEdit;
  final int minLines, maxLines;

  InputContent({this.content, this.confirmText, this.cancelText, this.label, this.hint, this.obscureText, this.minLines, this.maxLines,
    this.disableEdit,
    this.pasteButton,
    this.copyButton});

  @override
  State<StatefulWidget> createState() => _InputContentState();
}

class _InputContentState extends State<InputContent> {
  String _content;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
    _controller = TextEditingController();
    if (_content != null) _controller.text = _content;
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
    final labelStyle = theme.primaryTextTheme.subtitle;
    final bodyStyle = theme.textTheme.caption.copyWith(color: Colors.white);
    final outlineStyle = theme.primaryTextTheme.subhead.copyWith(color: theme.accentColor);
    final confirmText = widget.confirmText;
    final cancelText = widget.cancelText;
    final label = widget.label;
    final actions = <Widget>[
      Expanded(child: FlatButton(color: Color(0xFF7D7D7D), child: Text(cancelText ?? "", style: buttonStyle), onPressed: () => Navigator.pop(context))),
      SizedBox(width: 20),
      Expanded(child:
      FlatButton(color: theme.accentColor, disabledColor: Color(0xFF7D7D7D),child: Text(confirmText ?? "", style: buttonStyle), onPressed: _content != null && _content.isNotEmpty ? () => Navigator.pop(context, _content) : null)),
    ];
    if (confirmText == null || confirmText.isEmpty)
      actions.removeRange(1, actions.length);
    else if (cancelText == null || cancelText.isEmpty) actions.removeRange(0, actions.length - 1);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      label == null || label.isEmpty ? SizedBox() : Text(label, style: labelStyle),
      SizedBox(height: 10),
      TextField(
          controller: _controller,
          obscureText: widget.obscureText,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          enabled: widget.disableEdit != true,
          onChanged: (value) => setState(() => _content = value),
          decoration: createInputDecoration(
              hint: widget.hint,
              suffix: widget.pasteButton == true
                  ? InkWell(
                      child: Icon(Icons.content_paste, size: 10, color: Colors.white),
                      onTap: () async {
                        final text = await Clipboard.getData("text/plain");
                        setState(() => _content = text.text);
                        _controller.text = _content;
                      })
                  : null),
          style: bodyStyle),
      widget.copyButton == true ?
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          alignment: Alignment.center,
          child: OutlineButton(color: theme.accentColor, child: Text("复制", style: outlineStyle), onPressed: () => Clipboard.setData(ClipboardData(text: _content)))) : SizedBox(height: 20),
      Row(children: actions, mainAxisSize: MainAxisSize.max)
    ]);
  }
}

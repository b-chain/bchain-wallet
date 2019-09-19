import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GroupSwitch<T> extends StatefulWidget {

  final List<T> selectValues;
  final int selectedIndex;
  final GroupSwitchValue<T> switchValue;
  final GroupOnSelected<T> onSelected;

  GroupSwitch(this.selectValues, {this.selectedIndex = 0, this.onSelected, this.switchValue});

  @override
  State<StatefulWidget> createState() => GroupSwitchState();

}

class GroupSwitchState extends State<GroupSwitch> {

  int _selectedIndex = 0;
  GroupSwitchValue _valueConverter;

  PopupMenuItemSelected _onSelected;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _valueConverter = widget.switchValue ?? (v) => v.toString();
    _onSelected = (v) {
      final index = widget.selectValues.indexOf(v);
      if (widget.onSelected == null || !widget.onSelected(v, index)) setState(() => _selectedIndex = index);
    };
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final values = widget.selectValues;
    final value = values.length > 0 ? values[_selectedIndex] : null;
    return PopupMenuButton(onSelected: _onSelected,
        child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(children: <Widget>[
          Text(value == null ? "" : _valueConverter(value), style: theme.textTheme.body1),
          Icon(Icons.expand_more)
        ]), decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), color: theme.cardColor)), itemBuilder: (context) => widget.selectValues.map((v) => PopupMenuItem(
          value: v,
            child: Text(_valueConverter(v)))).toList());

  }

}

typedef GroupSwitchValue<T> = String Function(T value);
typedef GroupOnSelected<T> = bool Function(T value, int index);

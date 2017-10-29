import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:meta/meta.dart';

import 'package:numberpicker/numberpicker.dart';

import 'package:bankwitt/denomination.dart';

DateTime _dateEdited = new DateTime.now();
DateFormat _dateFormat = new DateFormat("EEE dd/MM/yyyy");

class DenominationEntryDialog extends StatefulWidget {
  final Denomination denominationToEdit;

  DenominationEntryDialog.add(this.denominationToEdit);

  DenominationEntryDialog.edit(this.denominationToEdit);

  @override
  DenominationEntryDialogState createState() {
    if (denominationToEdit != null) {
      return new DenominationEntryDialogState(
          denominationToEdit.id,
          denominationToEdit.count,
          denominationToEdit.value,
          denominationToEdit.userId,
          denominationToEdit.label,
          denominationToEdit.updated,
          denominationToEdit.total,
          denominationToEdit.name);
    } else {
      return new DenominationEntryDialogState(
          0, 0, 0.0, 0, '', _dateFormat.format(_dateEdited), '', '');
    }
  }
}

class DenominationEntryDialogState extends State<DenominationEntryDialog> {
  int _id;
  int _count;
  double _value;
  int _userId;
  String _label;
  String _updated;
  String _total;
  String _name;

  TextEditingController _textController;

  DenominationEntryDialogState(this._id, this._count, this._value, this._userId,
      this._label, this._updated, this._total, this._name);

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.denominationToEdit == null
          ? const Text("New entry")
          : const Text("Edit entry"),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop(new Denomination(
                _id, _count, _value, _userId, _label, _updated, _total, _name));
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    _textController = new TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(context),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.today, color: Colors.grey[500]),
            title: new DateTimeItem(
              dateTime: _dateFormat.parse(_updated),
              onChanged: (dateTime) => setState(() {
                    _updated = _dateFormat.format(dateTime);
                  }),
            ),
          ),
          new ListTile(
            title: new Text(
              "Count: $_count",
            ),
            onTap: () => _showCountPicker(context),
          ),
          new ListTile(
            title: new Text(
              "Value: \$ $_value",
            ),
            onTap: () => _showCountPicker(context),
          ),
          new ListTile(
            leading: new Icon(Icons.attach_money, color: Colors.grey[500]),
            title: new TextField(
              decoration: new InputDecoration(
                hintText: 'Name of denomination',
              ),
              controller: _textController,
              onChanged: (value) => _name = value,
            ),
          ),
        ],
      ),
    );
  }

  _showCountPicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.integer(
        minValue: 1,
        maxValue: 1000000000,
        initialIntegerValue: _count,
        title: new Text("Enter the number of $_name"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() => _count = value);
      }
    });
  }

  _showValuePicker(BuildContext context) {
    showDialog(
      context: context,
      child: new NumberPickerDialog.decimal(
        minValue: 1,
        maxValue: 1000000000,
        initialDoubleValue: _value,
        title: new Text("Enter the value of $_name"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _value = value;
          _updateTotal();
        });
      }
    });
  }

  void _updateTotal() {
    _total = getNumberFormat(_count, _value);
  }
}

String getNumberFormat(int count, double value) {
  var format = new NumberFormat("#,##0.00", "en_US");

  return '\$ ' + format.format((count * value) / 100);
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = dateTime == null
            ? new DateTime.now()
            : new DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = dateTime == null
            ? new DateTime.now()
            : new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;

  final TimeOfDay time;

  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            onTap: (() => _showDatePicker(context)),
            child: new Padding(
                padding: new EdgeInsets.symmetric(vertical: 8.0),
                child: new Text(new DateFormat('EEEE, MMMM d').format(date))),
          ),
        ),
        new InkWell(
          onTap: (() => _showTimePicker(context)),
          child: new Padding(
              padding: new EdgeInsets.symmetric(vertical: 8.0),
              child: new Text('$time')),
        ),
      ],
    );
  }

  Future _showDatePicker(BuildContext context) async {
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: date.subtract(const Duration(days: 20000)),
        lastDate: new DateTime.now());

    if (dateTimePicked != null) {
      onChanged(new DateTime(dateTimePicked.year, dateTimePicked.month,
          dateTimePicked.day, time.hour, time.minute));
    }
  }

  Future _showTimePicker(BuildContext context) async {
    TimeOfDay timeOfDay =
        await showTimePicker(context: context, initialTime: time);

    if (timeOfDay != null) {
      onChanged(new DateTime(
          date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute));
    }
  }
}

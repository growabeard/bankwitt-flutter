import 'dart:async';

import 'package:flutter/material.dart';

import 'package:meta/meta.dart';


import 'package:numberpicker/numberpicker.dart';

import 'package:bankwitt/denomination.dart';
import 'package:flutter/services.dart';


DateTime _dateEdited = new DateTime.now();


var bankWittUrl = 'bankwitt.herokuapp.com';
var httpClient = createHttpClient();

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
          denominationToEdit.name,
          denominationToEdit.shouldDelete);
    } else {
      return new DenominationEntryDialogState(
          0, 0, 0, 0, '', Denomination.dateFormat.format(_dateEdited), '', '', false);
    }
  }
}

class DenominationOption {
  int value;
  String name;
  String prettyName;

  DenominationOption(this.value, this.name, this.prettyName);
}

class DenominationEntryDialogState extends State<DenominationEntryDialog> {
  int _id;
  int _count;
  int _value;
  int _userId;
  String _label;
  String _updated;
  String _total;
  String _name;
  bool _shouldDelete;

  List<DenominationOption> _possibleNames = <DenominationOption>[
    new DenominationOption(1, 'penny', 'Penny'),
    new DenominationOption(5, 'nickel', 'Nickel'),
    new DenominationOption(10, 'dime', 'Dime'),
    new DenominationOption(25, 'quarter', 'Quarter'),
    new DenominationOption(50, 'half_dollar', 'Half Dollar'),
    new DenominationOption(100, 'dollar_coin', 'Dollar Coin'),
    new DenominationOption(100, 'dollar', 'Dollar Bill'),
    new DenominationOption(200, 'two_dollar', 'Two Dollar Bill'),
    new DenominationOption(500, 'five_dollar', 'Five Dollar Bill'),
    new DenominationOption(1000, 'ten_dollar', 'Ten Dollar Bill'),
    new DenominationOption(2000, 'twenty_dollar', 'Twenty Dollar Bill'),
    new DenominationOption(5000, 'fifty_dollar', 'Fifty Dollar Bill'),
    new DenominationOption(10000, 'hundred_dollar', 'Hundred Dollar Bill'),
  ];

  DenominationEntryDialogState(this._id, this._count, this._value, this._userId,
      this._label, this._updated, this._total, this._name, this._shouldDelete);
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  new GlobalKey<ScaffoldState>();

  Widget _createAppBar(BuildContext context) {
    return new AppBar(
      title: widget.denominationToEdit == null
          ? const Text("New entry")
          : const Text("Edit entry"),
      actions: [
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop(new Denomination(
                _id, _count, _value, _userId, Denomination.moneyFormat.format(_value / 100), _updated, _total, _name));
          },
          child: new Text('SAVE',
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white)),
        ),
        new IconButton(
          icon: new Icon(Icons.delete),
          tooltip: 'Delete denomination',
          onPressed: () {
            widget.denominationToEdit.shouldDelete = true;
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: _createAppBar(context),
      body: new Column(
        children: [
          new ListTile(
            leading: new Icon(Icons.today, color: Colors.grey[500]),
            title: new DateTimeItem(
              dateTime: Denomination.dateFormat.parse(_updated),
              onChanged: (dateTime) => setState(() {
                    _updated = Denomination.dateFormat.format(dateTime);
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
              "Value: " + Denomination.moneyFormat.format(_value / 100),
            ),
          ),
          new ListTile(
            title: const Text('Name:'),
            trailing: new DropdownButton<String>(
              value: _name,
              onChanged: (String newValue) {
                setState(() {
                  _name = newValue;
                  _value = _possibleNames.firstWhere((indName) => indName.name == _name).value;
                });
              },
              items: _possibleNames.map((DenominationOption value) {
                return new DropdownMenuItem<String>(
                  value: value.name,
                  child: new Text(value.prettyName),
                );
              }).toList(),
            ),
          ),
          new ListTile(
            title: new Text(
              "Total: $_total",
            ),
          ),
          new ListTile(
            title: new Text(
              "User: $_userId",
            ),
          ),
          new ListTile(
            title: new Text(
              _id == null ? "NEW" : "ID: $_id",
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
        minValue: 0,
        maxValue: 1000000000,
        initialIntegerValue: _count,
        title: new Text("Enter the number of $_name"),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _count = value;
          _updateTotal();
        });
      }
    });
  }

  void _updateTotal() {
    _total = Denomination.getNumberFormat(_count, _value);
  }

}



class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = dateTime == null
            ? new DateTime.now()
            : new DateTime(dateTime.year, dateTime.month, dateTime.day),
        super(key: key);

  final DateTime date;

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
                child: new Text(Denomination.dateFormat.format(date))),
          ),
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
          dateTimePicked.day));
    }
  }
}

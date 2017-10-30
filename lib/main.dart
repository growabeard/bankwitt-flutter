import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:bankwitt/denomination.dart';
import 'package:bankwitt/denominationEntryDialog.dart';

var httpClient = createHttpClient();
var bankWittUrl = 'bankwitt.herokuapp.com';


var User = {'first': 'Joseph', 'last': 'Moody', 'id': '1'};

class DenominationList extends StatefulWidget {
  DenominationList({Key key, this.denominations}) : super(key: key);

  List<Denomination> denominations = new List<Denomination>();

  // The framework calls createState the first time a widget appears at a given
  // location in the tree. If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework will re-use the State object
  // instead of creating a new State object.

  @override
  _DenominationListState createState() => new _DenominationListState();
}

class _DenominationListState extends State<DenominationList> {
  ScrollController _scrollController = new ScrollController();
  var url = new Uri.https(bankWittUrl, 'denominations', {'userId': '1'});

  int userId = 0;

  initState() {
    super.initState();
    _getDenominationList(1);
  }

  _getDenominationList(int userId) async {
    print('Getting denomination list');
    var url = new Uri.https(bankWittUrl, 'denominations', {'userId': '1'});
    var response = await httpClient.get(url);
    print('Got denomination list');
    Map denomInner = JSON.decode(response.body);
    print(denomInner['denominations'].toString());
    List<Denomination> mappedList = _createDenominations(denomInner['denominations']);
    setState(() {
      print('setting state..');
      widget.denominations = mappedList;
    });
  }

  _saveDenominationList() async {
    print('Saving denomination list');
    var url = new Uri.https(bankWittUrl, 'savedenominations');
    var body = "{\"denominations\": " + JSON.encode(widget.denominations) + ", \"user\": " + JSON.encode(User) + "}";
    print("BODY " + body);
    Map header = new Map();
    header['Content-Type'] = 'application/json';
    var response = await httpClient.post(url, body: body, headers: header);
    print(response.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
        appBar: new AppBar(title: new Text('Joseph Moody'), actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.add),
            tooltip: 'Add new denomination',
            onPressed: () {
              _openAddEntryDialog();
            },
          ),
          new IconButton(
            icon: new Icon(Icons.refresh),
            tooltip: 'Refresh denominations for User',
            onPressed: () {
              _getDenominationList(1);
            },
          ), new IconButton(
            icon: new Icon(Icons.save),
            tooltip: 'Save denominations for User',
            onPressed: () {
              _saveDenominationList();
            },
          )
        ]),
        body: new Column(children: <Widget>[
          new Expanded(
              child: new GridView.builder(
                controller: _scrollController,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              childAspectRatio:
                  (orientation == Orientation.portrait) ? 1.0 : 1.3,
            ),
            itemBuilder: (BuildContext context, int index) {
              return new DenominationListItem(
                  denomination: widget.denominations.elementAt(index));
            },
            itemCount: widget.denominations == null ? 0 : widget.denominations.length,
          )),
        ]));
  }

  List<Denomination> _createDenominations(List denomInner) {
    List<Denomination> denoms = new List<Denomination>();

    for(var denom in denomInner) {
      denoms.add(new Denomination(denom['id'], denom['count'], denom['value'],
          denom['userid'], denom['label'], denom['updated'], denom['total'],
          denom['name']));
    }

    return denoms;
  }

  void _addWeightSave(Denomination denominationToSave) {

    setState(() {

      widget.denominations.add(denominationToSave);

      _scrollController.animateTo(

        widget.denominations.length * 50.0,

        duration: const Duration(microseconds: 1),

        curve: new ElasticInCurve(0.01),

      );

    });

  }



  



  Future _openAddEntryDialog() async {

    Denomination save =

    await Navigator.of(context).push(new MaterialPageRoute<Denomination>(

        builder: (BuildContext context) {

          return new DenominationEntryDialog.add(new Denomination(0, 0, 0.0, userId, '', new DateFormat("EEE dd/MM/yyyy").format(new DateTime.now()), '\$ 0.00', ''));

        },

        fullscreenDialog: false));

    if (save != null) {

      _addWeightSave(save);

    }

  }
}

void main() {
  runApp(new MaterialApp(title: 'BankWitt', home: new DenominationList(),
  theme: new ThemeData.light()));
}

getUsers() async {
  var url = new Uri.http(bankWittUrl, 'users');
  var response = await httpClient.get(url);
  return response;
}

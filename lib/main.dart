import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'denomination.dart';
import 'package:numberpicker/numberpicker.dart';

var httpClient = createHttpClient();
var bankWittUrl = 'bankwitt.herokuapp.com';

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

  Set<Denomination> _denominationList = new Set<Denomination>();

  initState(){
    super.initState();
    _getDenominationList(1);
  }

  _getDenominationList(int userId) async {
    log('Getting denomination list');
    var url = new Uri.https(bankWittUrl, 'denominations', {'userId': '1'});
    var response = await httpClient.get(url);
    log('Got denomination list');
    Map data = JSON.decode(response.body);
    log(data['denominations'].toString());
    setState(() {
      widget.denominations = data['denominations'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    List<Denomination> emptyList = new List<Denomination>();
    emptyList.add(new Denomination(0, 0, 0.0, 0, 'empty', '', '', 'quarter'));
    widget.denominations = emptyList;

    return new Scaffold(
        appBar: new AppBar(
            title: new Text('Joseph Moody'),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.save),
                tooltip: 'Save Denominations for User',
                onPressed: () {
                  /* ... */
                },
              )
            ]
        ),
        body: new Column(
            children: <Widget>[
              new Expanded(
                child: new GridView.count(
                  crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  padding: const EdgeInsets.all(4.0),
                  childAspectRatio: (orientation == Orientation.portrait)
                      ? 1.0
                      : 1.3,
                  children: (widget.denominations == null) ? emptyList : widget.denominations.map((
                      Denomination denomination) {
                    return new DenominationListItem(
                      denomination: denomination);
                  }).toList(),
                ),
              ),
            ]
        )
    );
  }
}

void main() {
  runApp(new MaterialApp(
    title: 'BankWitt',
    home: new DenominationList( )
  ));
}

getUsers() async {
  var url = new Uri.http(bankWittUrl, 'users');
  var response = await httpClient.get(url);
  return response;
}
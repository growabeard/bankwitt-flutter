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


var User = {'name': 'Joseph Moody', 'id': '1'};

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
  var url = new Uri.https(bankWittUrl, 'denominations', {'userId': '1'});

  // Function to get the JSON data

//  Future<String> getJSONData() async {
//    var response = await http.get(
//
//        // Encode the url
//
//        url,
//
//        // Only accept JSON response
//
//        headers: {"Accept": "application/json"});
//
//    // Logs the response body to the console
//
//    print(response.body);
//
//    // To modify the state of the app, use this method
//
//    setState(() {
//      // Get the JSON data
//
//      var dataConvertedToJSON = JSON.decode(response.body);
//
//      // Extract the required part and assign it to the global variable named data
//
//      data = dataConvertedToJSON['denominations'];
//    });
//
//    return "Successfull";
//  }

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

  _saveDenominationList() async {}

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
        appBar: new AppBar(title: new Text('Joseph Moody'), actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.save),
            tooltip: 'Save Denominations for User',
            onPressed: () {
              _saveDenominationList();
            },
          ),
          new IconButton(
            icon: new Icon(Icons.refresh),
            tooltip: 'Refresh Denominations for User',
            onPressed: () {
              _getDenominationList(1);
            },
          )
        ]),
        body: new Column(children: <Widget>[
          new Expanded(
              child: new GridView.builder(
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
      denoms.add(new Denomination(denom['id'], denom['count'], denom['value'], denom['userId'], denom['label'], denom['updated'], denom['total'], denom['name']));
    }

    return denoms;
  }
}

void main() {
  runApp(new MaterialApp(title: 'BankWitt', home: new DenominationList()));
}

getUsers() async {
  var url = new Uri.http(bankWittUrl, 'users');
  var response = await httpClient.get(url);
  return response;
}

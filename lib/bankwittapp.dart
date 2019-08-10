import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:bankwitt/denomination.dart';
import 'package:bankwitt/user.dart';
import 'package:bankwitt/denominationEntryDialog.dart';
import 'package:http_auth/http_auth.dart';


var httpClient = new HttpClient();
var bankWittUrl = 'bankwitt.herokuapp.com';
var authHeader = 'Basic YnV0dHM6YnV0dHM=';

class BankWittApp extends StatefulWidget {
  BankWittApp({Key key, this.denominations, this.users, this.currentUser})
      : super(key: key);

  List<Denomination> denominations = new List<Denomination>();

  List<User> users = new List<User>();

  User currentUser = new User(-1, 'Pick', 'Me');

  String currentUserTotal = '';

  bool usersLoaded;

  // The framework calls createState the first time a widget appears at a given
  // location in the tree. If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework will re-use the State object
  // instead of creating a new State object.

  @override
  _BankWittAppState createState() => new _BankWittAppState();
}

class _BankWittAppState extends State<BankWittApp>
    with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _userRefreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  static const platform = const MethodChannel('samples.flutter.io/battery');

  AnimationController _controller;

  Animation<double> _drawerContentsOpacity;

  Animation<Offset> _drawerDetailsPosition;

  ScrollController _scrollController = new ScrollController();
  ScrollController _drawerScrollController = new ScrollController();

  initState() {
    super.initState();

    widget.usersLoaded = false;

    _getUserList();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );

    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  Future<String> readResponse(HttpClientResponse response) {
    var completer = new Completer();
    var contents = new StringBuffer();
    response.transform(Utf8Decoder()).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }

  Future _getDenominationList() async {
    _refreshIndicatorKey.currentState?.show();
    print('Getting denomination list');
    var url = new Uri.https(bankWittUrl, 'denominations',
        {'userId': widget.currentUser.id.toString()});
    HttpClientResponse response = await httpClient.getUrl(url).then((HttpClientRequest request) {
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Authorization', authHeader);
      return request.close();
    });
    print('Got denomination list');
    String reply = await response.transform(utf8.decoder).join();
    var decodedResponse = jsonDecode(reply);
    print(decodedResponse['denominations'].toString());
    List<Denomination> mappedList =
        _createDenominationsFromJSON(decodedResponse['denominations']);
    widget.currentUserTotal = Denomination.getTotalFormat(decodedResponse['total']);
    setState(() {
      print('setting state..');
      widget.denominations = mappedList;
    });
  }

  Future _getUserList() async {
    _userRefreshIndicatorKey.currentState?.show();
    print('Getting user list');
    var url = new Uri.https(bankWittUrl, 'users');
    var response = await httpClient.getUrl(url).then((HttpClientRequest request) {
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Authorization', authHeader);
      return request.close();
    });
    print('Got user list');
    List userInner = jsonDecode(await response.transform(utf8.decoder).join());
    print(userInner.toString());
    List<User> mappedList = _createUsersFromJSON(userInner);
    setState(() {
      print('setting state..');
      widget.users = mappedList;
      widget.usersLoaded = true;
    });
    _scaffoldKey.currentState.openDrawer();
  }

  Future<int> _saveDenominationList() async {
    print('Saving denomination list');
    var url = new Uri.https(bankWittUrl, 'savedenominations');
    var body = createJSONForSaving();
    print("BODY " + body);
    var response = await httpClient.postUrl(url).then((HttpClientRequest request) {
      request.headers.add('Content-Type', 'application/json');
      request.headers.add('Authorization', authHeader);
      request.write(body);
      return request.close();
    });
    print(response.statusCode);
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
          title: widget.currentUser == null
              ? new Text('Choose User')
              : new Text(widget.currentUser.last),
          actions: <Widget>[
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
                _getDenominationList();
              },
            ),
            new IconButton(
              icon: new Icon(Icons.save),
              tooltip: 'Save denominations for User',
              onPressed: () {
                Future<int> response = _saveDenominationList();
                response.then((responseCode) {
                  if (responseCode == 200) {
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                        content: new Text('Save success'),
                        action: new SnackBarAction(
                            label: 'SEND',
                            onPressed: () {
                              _sendBankWittStatement();
                            })));
                  } else {
                    _scaffoldKey.currentState.showSnackBar(new SnackBar(
                        content:
                            new Text('Save error ' + responseCode.toString())));
                  }
                });
              },
            ),
            new IconButton(
              icon: new Icon(Icons.share),
              tooltip: 'Share denominations for User',
              onPressed: () {
                _sendBankWittStatement();
              },
            )
          ]),
      body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _getDenominationList,
          child: new Column(children: <Widget>[
            new LinearProgressIndicator(
              value: widget.usersLoaded ? 0.0 : null
            ),
            new Text('TOTAL: ' + widget.currentUserTotal),
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
                    update: _updateDenominations,
                    denomination: widget.denominations.elementAt(index));
              },
              itemCount: widget.denominations == null
                  ? 0
                  : widget.denominations.length,
            )),
          ])),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: widget.currentUser == null
                  ? new Text('Choose User')
                  : new Text(widget.currentUser.getFullName()),
              accountEmail: new Text(''),
              currentAccountPicture: new CircleAvatar(
                  child: widget.currentUser == null
                      ? new Text('')
                      : new Text(widget.currentUser.getInitials())),
            ),
            new Expanded(
              child: new ListView.builder(
                controller: _drawerScrollController,
                itemBuilder: (BuildContext context, int index) {
                  User insideUser = widget.users.elementAt(index);
                  return new ListTile(
                      leading: new CircleAvatar(
                          child: new Text(insideUser.getInitials())),
                      title: new Text(insideUser.getFullName()),
                      onTap: () {
                        _changeUser(insideUser, context);
                      });
                },
                itemCount: widget.users == null ? 0 : widget.users.length,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add account'),
              onTap: _showNotImplementedMessage,
            ),
            new ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Manage accounts'),
              onTap: _showNotImplementedMessage,
            ),
            new AboutListTile()
          ],
        ),
      ),
    );
  }

  void _showNotImplementedMessage() {
    Navigator.of(context).pop(); // Dismiss the drawer.

    _scaffoldKey.currentState.showSnackBar(const SnackBar(
        content: const Text("The drawer's items don't do anything")));
  }

  _changeUser(User userToChangeTo, BuildContext context) {
    Navigator.of(context).pop();

    setState(() {
      if (widget.denominations != null) {
        widget.denominations.clear();
      }
      widget.currentUser = userToChangeTo;
    });

    _getDenominationList();
  }

  List<Denomination> _createDenominationsFromJSON(List denomInner) {
    List<Denomination> denoms = new List<Denomination>();

    for (var denom in denomInner) {
      denoms.add(new Denomination(
          denom['id'],
          denom['count'],
          denom['value'],
          denom['userid'],
          denom['label'],
          denom['updated'],
          denom['total'],
          denom['name']));
    }

    return denoms;
  }

  void _addDenomination(Denomination denominationToSave) {
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
              return new DenominationEntryDialog.add(new Denomination(
                  null,
                  0,
                  1,
                  widget.currentUser.id,
                  '\$ 0.01',
                  Denomination.dateFormat.format(new DateTime.now()),
                  '\$ 0.00',
                  'penny'));
            },
            fullscreenDialog: false));

    if (save != null) {
      bool contains = false;
      widget.denominations.forEach((denom) {
        if (save.name == denom.name) {
          contains = true;
        }
      });
      if (save.shouldDelete == true) {
        _maybeDelete(save);
      } else {
        if (!contains) {
          _addDenomination(save);
        } else {
          _scaffoldKey.currentState.showSnackBar(
              new SnackBar(content: new Text(save.name + ' is already here.')));
        }
      }
    }
  }

  void _maybeDelete(Denomination toDelete) {
    if (toDelete.id == null) {
      Navigator.of(context).pop();
    } else {
      _deleteDenomination(toDelete);
      setState(() {
        widget.denominations.remove(toDelete);
      });
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text('Deleted denomination.'),
          duration: new Duration(seconds: 10),
          action: new SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                _addDenomination(toDelete);
              })));
    }
  }

  Future<int> _deleteDenomination(Denomination toDelete) async {
    print('Deleting denomination ' + toDelete.toString());
    var url = new Uri.https(bankWittUrl, 'denominations',
        {'denominationId': toDelete.id.toString()});
    var response = await httpClient.deleteUrl(url).then((HttpClientRequest request) {
        request.headers.add('Content-Type', 'application/json');
        request.headers.add('Authorization', authHeader);
        return request.close();
    });
    print(response.statusCode);
    return response.statusCode;
  }

  List<User> _createUsersFromJSON(List userList) {
    List<User> users = new List<User>();

    for (var user in userList) {
      users.add(new User(user['id'], user['first'], user['last']));
    }

    return users;
  }

  String createJSONForSaving() {
    return "{\"denominations\": " +
        jsonEncode(widget.denominations) +
        ", \"user\": " +
        jsonEncode(widget.currentUser) +
        ", \"total\": " +
        jsonEncode(widget.currentUserTotal) +
        "}";
  }

  Future<Null> _sendBankWittStatement() async {
    String statement = createJSONForSaving();
    final int result =
        await platform.invokeMethod('getBatteryLevel', statement);
    String snackBarText = 'WHAT HAPPEN!? ' + result.toString();

    if (result == -1) {
      snackBarText = 'ERROR! TRY AGAIN.';
    } else if (result == 1) {
      snackBarText = 'SENT STATEMENT!';
    }
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(snackBarText)));
  }

  _updateDenominations() {
    int centsTotal = 0;
    for (var denom in widget.denominations) {
      if (denom.shouldDelete) {
        _maybeDelete(denom);
      } else {
        centsTotal += denom.count * denom.value;
      }
    }
    setState(() {
      widget.currentUserTotal =
          Denomination.getTotalFormat(centsTotal.toString());
    });
  }
}

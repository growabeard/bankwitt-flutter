import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:bankwitt/denomination.dart';
import 'package:bankwitt/user.dart';
import 'package:bankwitt/denominationEntryDialog.dart';

var httpClient = createHttpClient();
var bankWittUrl = 'bankwitt.herokuapp.com';

class DenominationList extends StatefulWidget {
  DenominationList({Key key, this.denominations, this.users, this.currentUser}) : super(key: key);

  List<Denomination> denominations = new List<Denomination>();

  List<User> users = new List<User>();

  User currentUser = new User(0, 'Pick', 'Me');

  // The framework calls createState the first time a widget appears at a given
  // location in the tree. If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework will re-use the State object
  // instead of creating a new State object.

  @override
  _DenominationListState createState() => new _DenominationListState();
}

class _DenominationListState extends State<DenominationList>  with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _userRefreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  AnimationController _controller;

  Animation<double> _drawerContentsOpacity;

  Animation<Offset> _drawerDetailsPosition;

  ScrollController _scrollController = new ScrollController();

  int userId = 1;

  initState() {
    super.initState();

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

      ).animate(new CurvedAnimation(

        parent: _controller,

        curve: Curves.fastOutSlowIn,

      ));
  }

  Future _getDenominationList() async {
    _refreshIndicatorKey.currentState?.show();
    print('Getting denomination list');
    var url = new Uri.https(bankWittUrl, 'denominations', {'userId': widget.currentUser.id.toString()});
    var response = await httpClient.get(url);
    print('Got denomination list');
    Map denomInner = JSON.decode(response.body);
    print(denomInner['denominations'].toString());
    List<Denomination> mappedList =
        _createDenominations(denomInner['denominations']);
    setState(() {
      print('setting state..');
      widget.denominations = mappedList;
    });
  }

  Future _getUserList() async {
    _userRefreshIndicatorKey.currentState?.show();
    print('Getting user list');
    var url = new Uri.https(bankWittUrl, 'users');
    var response = await httpClient.get(url);
    print('Got user list');
    List userInner = JSON.decode(response.body);
    print(userInner.toString());
    List<User> mappedList =
    _createUsers(userInner);
    setState(() {
      print('setting state..');
      widget.users = mappedList;
    });
  }

  Future<int> _saveDenominationList() async {
    print('Saving denomination list');
    var url = new Uri.https(bankWittUrl, 'savedenominations');
    var body = "{\"denominations\": " +
        JSON.encode(widget.denominations) +
        ", \"user\": " +
        JSON.encode(User) +
        "}";
    print("BODY " + body);
    Map header = new Map();
    header['Content-Type'] = 'application/json';
    var response = await httpClient.post(url, body: body, headers: header);
    print(response.statusCode);
    return response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return new Scaffold(
      key: _scaffoldKey,
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
                    action:
                        new SnackBarAction(label: 'SEND', onPressed: () {})));
              } else {
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content:
                        new Text('Save error ' + responseCode.toString())));
              }
            });
          },
        )
      ]),
      body: new RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _getDenominationList,
          child: new Column(children: <Widget>[
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
              itemCount: widget.denominations == null
                  ? 0
                  : widget.denominations.length,
            )),
          ])),
      drawer: new Drawer(
          child: new RefreshIndicator(
    key: _refreshIndicatorKey,
    onRefresh: _getUserList,
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(widget.currentUser.getFullName()),
              accountEmail: new Text('User email..'),
              currentAccountPicture: new CircleAvatar(child: new Text('JM')
              ),
            ),
            new ClipRect(
              child: new Stack(
                children: <Widget>[
                  // The initial contents of the drawer.

                  new FadeTransition(
                    opacity: _drawerContentsOpacity,
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.users.map((User user) {
                        return new ListTile(
                          leading: new CircleAvatar(child: new Text(user.getInitials())),
                          title: new Text(user.getFullName()),
                          onTap: _changeUser(user, context),
                        );
                      }).toList(),
                    ),
                  ),

                  // The drawer's "details" view.

                  new SlideTransition(
                    position: _drawerDetailsPosition,
                    child: new FadeTransition(
                      opacity: new ReverseAnimation(_drawerContentsOpacity),
                      child: new Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          new ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('Manage accounts'),
                            onTap: _showNotImplementedMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
      ),
    );
  }

  void _showNotImplementedMessage() {

    Navigator.of(context).pop(); // Dismiss the drawer.

    _scaffoldKey.currentState.showSnackBar(const SnackBar(

        content: const Text("The drawer's items don't do anything")

    ));

  }

  _changeUser(User userToChangeTo, BuildContext context) {
    Navigator.of(context).pop();

    setState(() {
      widget.denominations.clear();
      widget.currentUser = userToChangeTo;
    });
    _getDenominationList();
  }

  List<Denomination> _createDenominations(List denomInner) {
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
              return new DenominationEntryDialog.add(new Denomination(
                  null,
                  0,
                  1,
                  userId,
                  '\$ 0.01',
                  new DateFormat("EEE dd/MM/yyyy").format(new DateTime.now()),
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
      if (!contains) {
        _addWeightSave(save);
      } else {
        _scaffoldKey.currentState.showSnackBar(
            new SnackBar(content: new Text(save.name + ' is already here.')));
      }
    }
  }

  List<User> _createUsers(List userList) {
    List<User> users = new List<User>();

    for (var user in userList) {
      users.add(new User(user['id'], user['first'], user['last']));
    }

    return users;
  }
}

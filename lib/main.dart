import 'package:flutter/material.dart';
import 'denomination.dart';

class ShoppingList extends StatefulWidget {
  ShoppingList({Key key, this.denominations}) : super(key: key);

  final List<Denomination> denominations;

  // The framework calls createState the first time a widget appears at a given
  // location in the tree. If the parent rebuilds and uses the same type of
  // widget (with the same key), the framework will re-use the State object
  // instead of creating a new State object.

  @override
  _ShoppingListState createState() => new _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Set<Denomination> _shoppingCart = new Set<Denomination>();

  void _handleCartChanged(Denomination denomination, bool inCart) {
    setState(() {
      // When user changes what is in the cart, we need to change _shoppingCart
      // inside a setState call to trigger a rebuild. The framework then calls
      // build, below, which updates the visual appearance of the app.

      if (inCart)
        _shoppingCart.add(denomination);
      else
        _shoppingCart.remove(denomination);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Shopping List'),
      ),
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: widget.denominations.map((Denomination denomination) {
          return new ShoppingListItem(
            denomination: denomination,
            inCart: _shoppingCart.contains(denomination),
            onCartChanged: _handleCartChanged,
          );
        }).toList(),
      ),
    );
  }
}

void main() {
  runApp(new MaterialApp(
    title: 'Shopping App',
    home: new ShoppingList(
      denominations: <Denomination>[
        new Denomination(name: 'Eggs'),
        new Denomination(name: 'Flour'),
        new Denomination(name: 'Chocolate chips'),
      ],
    ),
  ));
}

//void main() {
//  runApp(new MyApp());
//}
//
//class MyApp extends StatelessWidget {
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      title: 'BankWitt',
//      theme: new ThemeData(
//        primarySwatch: Colors.blueGrey,
//      ),
//      home: new MyHomePage(title: 'Joe Moody'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  // This widget is the home page of your application. It is stateful,
//  // meaning that it has a State object (defined below) that contains
//  // fields that affect how it looks.
//
//  // This class is the configuration for the state. It holds the
//  // values (in this case the title) provided by the parent (in this
//  // case the App widget) and used by the build method of the State.
//  // Fields in a Widget subclass are always marked "final".
//
//  final String title;
//
//  @override
//  _ExpansionPanelsDemoState createState() => new _ExpansionPanelsDemoState();
//}
//
//typedef Widget DemoItemBodyBuilder<T>(DemoItem<T> item);
//
//typedef String ValueToString<T>(T value);
//
//class DualHeaderWithHint extends StatelessWidget {
//  const DualHeaderWithHint({this.name, this.value, this.hint, this.showHint});
//
//  final String name;
//
//  final String value;
//
//  final String hint;
//
//  final bool showHint;
//
//  Widget _crossFade(Widget first, Widget second, bool isExpanded) {
//    return new AnimatedCrossFade(
//      firstChild: first,
//      secondChild: second,
//      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
//      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
//      sizeCurve: Curves.fastOutSlowIn,
//      crossFadeState:
//      isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//      duration: const Duration(milliseconds: 200),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final ThemeData theme = Theme.of(context);
//
//    final TextTheme textTheme = theme.textTheme;
//
//    return new Row(children: <Widget>[
//      new Expanded(
//        flex: 2,
//        child: new Container(
//          margin: const EdgeInsets.only(left: 24.0),
//          child: new FittedBox(
//            fit: BoxFit.scaleDown,
//            alignment: FractionalOffset.centerLeft,
//            child: new Text(
//              name,
//              style: textTheme.body1.copyWith(fontSize: 15.0),
//            ),
//          ),
//        ),
//      ),
//      new Expanded(
//          flex: 3,
//          child: new Container(
//              margin: const EdgeInsets.only(left: 24.0),
//              child: _crossFade(
//                  new Text(value,
//                      style: textTheme.caption.copyWith(fontSize: 15.0)),
//                  new Text(hint,
//                      style: textTheme.caption.copyWith(fontSize: 15.0)),
//                  showHint)))
//    ]);
//  }
//}
//
//class CollapsibleBody extends StatelessWidget {
//  const CollapsibleBody(
//      {this.margin: EdgeInsets.zero, this.child, this.onSave, this.onCancel});
//
//  final EdgeInsets margin;
//
//  final Widget child;
//
//  final VoidCallback onSave;
//
//  final VoidCallback onCancel;
//
//  @override
//  Widget build(BuildContext context) {
//    final ThemeData theme = Theme.of(context);
//
//    final TextTheme textTheme = theme.textTheme;
//
//    return new Column(children: <Widget>[
//      new Container(
//          margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0) -
//              margin,
//          child: new Center(
//              child: new DefaultTextStyle(
//                  style: textTheme.caption.copyWith(fontSize: 15.0),
//                  child: child))),
//      const Divider(height: 1.0),
//      new Container(
//          padding: const EdgeInsets.symmetric(vertical: 16.0),
//          child: new Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                new Container(
//                    margin: const EdgeInsets.only(right: 8.0),
//                    child: new FlatButton(
//                        onPressed: onCancel,
//                        child: const Text('CANCEL',
//                            style: const TextStyle(
//                                color: Colors.black54,
//                                fontSize: 15.0,
//                                fontWeight: FontWeight.w500)))),
//                new Container(
//                    margin: const EdgeInsets.only(right: 8.0),
//                    child: new FlatButton(
//                        onPressed: onSave,
//                        textTheme: ButtonTextTheme.accent,
//                        child: const Text('SAVE')))
//              ]))
//    ]);
//  }
//}
//
//class DemoItem<T> {
//  DemoItem({this.name, this.value, this.hint, this.builder, this.valueToString, this.count})
//      : textController = new TextEditingController(text: valueToString(value));
//
//  final String name;
//
//  final String hint;
//
//  final int count;
//
//  final TextEditingController textController;
//
//  final DemoItemBodyBuilder<T> builder;
//
//  final ValueToString<T> valueToString;
//
//  T value;
//
//  bool isExpanded = false;
//
//  ExpansionPanelHeaderBuilder get headerBuilder {
//    return (BuildContext context, bool isExpanded) {
//      return new DualHeaderWithHint(
//          name: name,
//          value: count.toString(),
//          hint: hint,
//          showHint: isExpanded);
//    };
//  }
//}
//
//class ExpasionPanelsDemo extends StatefulWidget {
//  static const String routeName = '/material/expansion_panels';
//
//  @override
//  _ExpansionPanelsDemoState createState() => new _ExpansionPanelsDemoState();
//}
//
//class AccountHolder {
//  String initials;
//  String name;
//  int id;
//
//  AccountHolder(String inInitials, String inName, int inId) {
//    this.id = inId;
//    this.initials = inInitials;
//    this.name = inName;
//  }
//}
//
//class Denomination {
//  int id;
//  int count;
//  double value;
//  int userId;
//  String label;
//  String updated;
//  String total;
//
//  Denomination(int id, int count, double value, int userId, String label, String updated, String total) {
//    this.id = id;
//    this.count = count;
//    this.value = value;
//    this.userId = userId;
//    this.label = label;
//    this.updated = updated;
//    this.total = total;
//  }
//}
//
//class _ExpansionPanelsDemoState extends State<MyHomePage> {
//  List<DemoItem<dynamic>> _demoItems;
//
//  List<AccountHolder> _drawerContents = <AccountHolder>[
//    new AccountHolder('JM', 'Joseph Moody', 1),
//    new AccountHolder('AM', 'Andrew Mather', 2),
//    new AccountHolder('AW', 'Aaron Williams', 3),
//    new AccountHolder('VZ', 'Vincent Zickefoose', 4),
//    new AccountHolder('DM', 'Daniel Marchetti', 5),
//  ];
//
//  List<Denomination> _denominations = <Denomination>[
//    new Denomination(
//        1,
//        2,
//        0.10,
//        1,
//        '\$0.10',
//        '06/01/2017',
//        '\$0.20'),
//    new Denomination(
//        1,
//        5,
//        0.25,
//        1,
//        '\$0.25',
//        '06/01/2017',
//        '\$1.25'),
//  ];
//
//  @override
//  void initState() {
//    super.initState();
//
//    _demoItems = _denominations.map((Denomination denomination) {
//      return new DemoItem<Denomination>(
//        name: denomination.label,
//        count: denomination.count,
//        hint: 'Edit denomination',
//        value: denomination,
//        builder: (DemoItem<Denomination> item) {
//          void close() {
//            setState(() {
//              item.isExpanded = false;
//            });
//          }
//
//          return new Form(
//            child: new Builder(
//              builder: (BuildContext context) {
//                return new CollapsibleBody(
//                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                  onSave: () {
//                    Form.of(context).save();
//                    close();
//                  },
//                  onCancel: () {
//                    Form.of(context).reset();
//                    close();
//                  },
//                  child: new Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                    child: new TextFormField(
//                      controller: item.textController,
//                      decoration: new InputDecoration(
//                        hintText: item.hint,
//                        labelText: item.name,
//                      ),
//                      onSaved: (String value) {
//                        item.value.count = int.parse(value);
//                      },
//                    ),
//                  ),
//                );
//              },
//            ),
//          );
//        },
//      );
//    }).toList();
//  }
//
//    @override
//    Widget build(BuildContext context) {
//      return new Scaffold(
//          appBar: new AppBar(
//            title: new Text(widget.title),
//          ),
//          drawer: new Drawer(
//            child: new ListView(
//                children: _drawerContents.map((AccountHolder holder) {
//                  return new ListTile(
//                    leading: new CircleAvatar(child: new Text(holder.initials)),
//                    title: new Text(holder.name),
//                    onTap: () {
//                      Navigator.pop(context);
//                    },
//                  );
//                }).toList()),
//          ),
//          body: new SingleChildScrollView(
//              child: new Container(
//                  margin: const EdgeInsets.all(24.0),
//                  child: new ExpansionPanelList(
//                      expansionCallback: (int index, bool isExpanded) {
//                        setState(() {
//                          _demoItems[index].isExpanded = !isExpanded;
//                        });
//                      },
//                      children: _demoItems.map((DemoItem<dynamic> item) {
//                        return new ExpansionPanel(
//                            isExpanded: item.isExpanded,
//                            headerBuilder: item.headerBuilder,
//                            body: item.builder(item));
//                      }).toList()))));
//    }
//  }
//

import 'package:flutter/material.dart';

class Denomination {
  final int id;
  final int count;
  final double value;
  final int userId;
  final String label;
  final String updated;
  final String total;
  final String name;

  const Denomination(this.id, this.count, this.value, this.userId, this.label,
      this.updated, this.total, {this.name});
}

typedef void CartChangedCallback(Denomination denomination, bool inCart);

class ShoppingListItem extends StatelessWidget {
  ShoppingListItem({Denomination denomination, this.inCart, this.onCartChanged})
      : denomination= denomination,
        super(key: new ObjectKey(denomination));

  final Denomination denomination;
  final bool inCart;
  final CartChangedCallback onCartChanged;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different parts of the tree
    // can have different themes.  The BuildContext indicates where the build is
    // taking place and therefore which theme to use.

    return inCart ? Colors.black54 : Theme.of(context).primaryColor;
  }

  TextStyle _getTextStyle(BuildContext context) {
    if (!inCart) return null;

    return new TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        children: <Widget>[
         new Expanded(
           child:
             new Text(denomination.label),
         )
        ]
    );
//    return new ListTile(
//      onTap: () {
//        onCartChanged(denomination, !inCart);
//      },
//      leading: new CircleAvatar(
//        backgroundColor: _getColor(context),
//        child: new Text(denomination.name[0]),
//      ),
//      title: new Text(denomination.name, style: _getTextStyle(context)),
//    );
  }
}
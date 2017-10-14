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
      this.updated, this.total, this.name);


}

typedef void CartChangedCallback(Denomination denomination, bool inCart);

class DenominationListItem extends StatelessWidget {
  DenominationListItem({Denomination denomination, this.inCart})
      : denomination= denomination,
        super(key: new ObjectKey(denomination));

  final Denomination denomination;
  final bool inCart;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different parts of the tree
    // can have different themes.  The BuildContext indicates where the build is
    // taking place and therefore which theme to use.

    return inCart ? Colors.black54 : Theme
        .of(context)
        .primaryColor;
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
    var item;
    final Widget image = new GestureDetector(
        child: new Hero(
            key: new Key(denomination.name),
            tag: denomination.label,
            child: new Image.asset(
              'images/' + denomination.name + '.png',
              fit: BoxFit.cover,
            )
        )
    );
    var emptyItem = new GridTile(
      child: image, footer: new GestureDetector(child:
      new GridTileBar(
        backgroundColor: Colors.black87,
        title: new _GridTitleText('Retrieving items..'),
        subtitle: new _GridTitleText('Check back in a bit..'),
      )),);

    var filledItem = new GridTile(
      footer: new GestureDetector(
        onTap: () {
          onBannerTap(denomination);
        },
        child: new GridTileBar(
          backgroundColor: Colors.black87,
          title: new _GridTitleText(denomination.total),
          subtitle: new _GridTitleText(denomination.count.toString()),
          trailing: new Row(
              children: [
                new IconButton(
                  icon: new Icon(
                    Icons.remove,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    /* ... */
                  },
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.add,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    /* ... */
                  },
                ),
              ]
          ),
        ),
      ),
      child: image,
    );

    denomination.name == 'empty' ? item = emptyItem : item = filledItem;

    return item;
  }

  void onBannerTap(photo) {}
}


class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return new FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: new Text(text),
    );
  }
}
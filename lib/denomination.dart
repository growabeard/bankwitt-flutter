import 'package:flutter/material.dart';

class Denomination {
  int id;
  int count;
  double value;
  int userId;
  String label;
  String updated;
  String total;
  String name;

  Denomination(this.id, this.count, this.value, this.userId, this.label,
      this.updated, this.total, this.name);
}

typedef void CartChangedCallback(Denomination denomination, bool inCart);

class DenominationListItem extends StatelessWidget {
  DenominationListItem({Denomination denomination})
      : denomination = denomination,
        super(key: new ObjectKey(denomination));

  Denomination denomination;

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

    denomination.name == 'empty' ? item = emptyItem : item = new GridTile(
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
                    denomination.count--;
                  },
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.add,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    denomination.count++;
                  },
                ),
              ]
          ),
        ),
      ),
      child: image,
    );

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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bankwitt/denominationEntryDialog.dart';


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
      this.updated, this.total, this.name){
    total = getNumberFormat(count, value);
  }

  Map toJson() {
    Map map = new Map();
    map['id'] = this.id;
    map['count'] = this.count;
    map['value'] = this.value;
    map['userid'] = this.userId;
    map['label'] = this.label;
    map['updated'] = this.updated;
    map['total'] = this.total;
    map['name'] = this.name;
    return map;
  }

}

String getNumberFormat(int count, double value) {
  var format = new NumberFormat("#,##0.00", "en_US");

  return '\$ ' + format.format((count * value) / 100);
}

class DenominationListItem extends StatefulWidget {
  DenominationListItem({Denomination denomination})
      : denomination = denomination,
        super(key: new ObjectKey(denomination));

  Denomination denomination;

  @override
  State<StatefulWidget> createState() => new _DenominationTileState();
}

class _DenominationTileState extends State<DenominationListItem> {


  @override
  Widget build(BuildContext context) {
    final Widget image = new GestureDetector(
        child: new Hero(
            key: new Key(widget.denomination.name),
            tag: widget.denomination.label,
            child: new Image.asset(
              'images/' + widget.denomination.name + '.png',
              fit: BoxFit.cover,
            )
        ),
      onTap: (){
        _editEntry(widget.denomination);
      }
    );

    return new GridTile(
      footer: new GestureDetector(
        onTap: () {
          onBannerTap(widget.denomination);
        },
        child: new GridTileBar(
          backgroundColor: Colors.black87,
          title: new _GridTitleText(widget.denomination.total),
          subtitle: new _GridTitleText(widget.denomination.count.toString()),
          trailing: new Row(
              children: [
                new IconButton(
                  icon: new Icon(
                    Icons.remove,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState((){
                      if (widget.denomination.count <= 0) { return; }
                      widget.denomination.count--;
                      updateTotal();
                    });
                  },
                  tooltip: 'Subtract from Count',
                  splashColor: Colors.white,
                ),
                new IconButton(
                  icon: new Icon(
                    Icons.add,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState((){
                      widget.denomination.count++;
                      updateTotal();
                    });
                  },
                  tooltip: 'Add to Count',
                  splashColor: Colors.white,
                ),
              ]
          ),
        ),
      ),
      child: image,
    );
  }

  _editEntry(Denomination denominationEdit) {

    Navigator

        .of(context)

        .push(

      new MaterialPageRoute<Denomination>(

        builder: (BuildContext context) {

          return new DenominationEntryDialog.edit(denominationEdit);

        },

        fullscreenDialog: false,

      ),

    )

        .then((newSave) {

      if (newSave != null) {

        setState(() => widget.denomination = newSave);

      }

    });

  }

  String updateTotal() {
    return widget.denomination.total = getNumberFormat(widget.denomination.count, widget.denomination.value);
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
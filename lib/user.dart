import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bankwitt/denominationEntryDialog.dart';


class User {
  int id;
  String first;
  String last;

  User(this.id,  this.first, this.last){
  }

  Map toJson() {
    Map map = new Map();
    map['id'] = this.id;
    map['first'] = this.first;
    map['last'] = this.last;
    return map;
  }

  String getFullName() {
    return this.first + ' ' + this.last;
  }

  String getInitials() {
    return this.first.substring(0,1) + this.last.substring(0, 1);
  }

}

class UserListItem extends StatefulWidget {
  UserListItem({User user})
      : user = user,
        super(key: new ObjectKey(user));

  User user;

  @override
  State<StatefulWidget> createState() => new _UserTileState();
}

class _UserTileState extends State<UserListItem> {


  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(widget.user.first),
    );
  }
}
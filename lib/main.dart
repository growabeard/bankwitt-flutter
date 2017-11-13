import 'dart:developer';

import 'package:bankwitt/denominationList.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(new MaterialApp(
      title: 'BankWitt',
      home: new Scaffold(body: new DenominationList(),
  )));

  }

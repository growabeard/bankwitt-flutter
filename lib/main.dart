import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bankwitt/bankwittapp.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(new MaterialApp(
      title: 'BankWitt',
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      supportedLocales: [const Locale('en', 'US')],
      home: new Scaffold(body: new BankWittApp(),
  )));

  }

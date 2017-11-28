import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bankwitt/bankwittapp.dart';
import 'package:flutter/material.dart';



void main() {
  runApp(new MaterialApp(
      title: 'BankWitt',
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      supportedLocales: [const Locale('en', 'US')],
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: new Scaffold(body: new BankWittApp(),
  )));

  }

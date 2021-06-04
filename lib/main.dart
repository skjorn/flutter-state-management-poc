import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/random_words.dart';
import 'package:flutter_startup_namer/services/connectivity_service.dart';

final connectivityService = ConnectivityService();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
        textTheme: TextTheme(
          subtitle1: TextStyle(fontSize: 18),
        ),
      ),
      home: RandomWords(connectivityService: connectivityService,),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/random_words.dart';
import 'package:flutter_startup_namer/services/connectivity_service.dart';
import 'package:flutter_startup_namer/services/name_data_service.dart';
import 'package:get/get.dart';

void main() {
  Get.put(ConnectivityService());
  Get.create(() => NameDataService());
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
      home: RandomWords(),
    );
  }
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/state/name.dart';
import 'package:get/get.dart';

// ignore: non_constant_identifier_names
MaterialPageRoute<void> SavedWordsRoute() {
  return MaterialPageRoute<void>(
    builder: (BuildContext context) {
      /// This is a new route, so we fetch the state here again to avoid tight
      /// coupling between screens.
      final _sharedState = Get.put(NameState(), permanent: true);
      final items = _sharedState.saved.map((WordPair pair) {
          return ListTile(
            title: Text(pair.asPascalCase),
          );
      });

      final divided = ListTile
          .divideTiles(
            context: context,
            tiles: items
          )
          .toList();

      return Scaffold(
          appBar: AppBar(
            title: const Text('Saved Suggestions'),
          ),
          body: ListView(children: divided,)
      );
    },
    fullscreenDialog: true,
  );
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
MaterialPageRoute<void> SavedWordsRoute(Set<WordPair> wordPairs) {
  return MaterialPageRoute<void>(
    builder: (BuildContext context) {
      final items = wordPairs.map(
              (WordPair pair) {
            return ListTile(
              title: Text(pair.asPascalCase),
            );
          }
      );

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

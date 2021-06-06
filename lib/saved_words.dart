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
          return _ListItem(pair);
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

// List Item

/// Ephemeral state -- we don't need it with what have been established.
/// But for quick, dirty, local prototyping it's tolerated.
/// (Although honestly, it's actually more code!)
class _ListItem extends StatefulWidget {
  final WordPair _wordPair;

  _ListItem(this._wordPair);

  @override
  _ListItemState createState() => _ListItemState(_wordPair);
}

class _ListItemState extends State<_ListItem> {
  final WordPair _wordPair;

  var _isImportant = false;

  _ListItemState(this._wordPair);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_wordPair.asPascalCase),
      trailing: _isImportant ? Icon(Icons.error_outline) : null,
      onTap: () => setState(() => _isImportant = !_isImportant),
    );
  }
}
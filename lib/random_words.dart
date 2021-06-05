import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/saved_words.dart';
import 'package:flutter_startup_namer/services/connectivity_service.dart';
import 'package:flutter_startup_namer/state/name.dart';
import 'package:get/get.dart';

class RandomWords extends StatelessWidget {
  /// We'll use GetX library for shared state, like this.
  /// State will not be a global object of all possible states, but rather scoped
  /// into chunks of arbitrary granularity, which are isolated, see folder 'state'.
  /// Generally speaking, every larger hierarchy of widgets will have its own State.
  /// We'll use 'tags' parameter for widgets that are used in multiple places
  /// to avoid collisions.
  final _sharedState = Get.put(NameState(), permanent: true);

  /// Other services (that may contain their own state) are injected via GetX as well.
  /// Here however, we don't create them for the first time. Instead we assume
  /// they were already initialized by the parent code.
  /// Services should also use reactive streams for their state.
  final ConnectivityService _connectivityService = Get.find();

  final List<WordPair> _suggestions = <WordPair>[];

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
          leading: IconButton(icon: Icon(Icons.swap_vert), onPressed: _toggleTextTransformation,),
          actions: [
            IconButton(icon: Icon(Icons.list), onPressed: () => _pushSaved(context),),
            IconButton(icon: Icon(Icons.network_cell), onPressed: () => _connectivityService.checkConnection(),)
          ],
          backgroundColor: _connectivityService.status.value.color,
        ),
        body: _buildSuggestions(),
      )
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) {
          return Divider();
        }

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index], _sharedState.transformation, _sharedState.saved);
      },
    );
  }

  /// It's ok (and even more transparent) to send reactive streams rather than
  /// the whole state down the hierarchy. It's a preferred way within, let's say,
  /// one screen or a complex part of a screen.
  /// (So Main widget/Route fetches the state via GetX and passes down reactive
  /// streams via params to children.)
  Widget _buildRow(WordPair pair, Rx<TextTransformation> transformation, RxSet<WordPair> saved) {
    return Obx(() {
      final isSaved = saved.contains(pair);
      return ListTile(
        title: Text(
            pair.transformed(transformation.value)
        ),
        trailing: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? Colors.red : null
        ),
        onTap: () {
          if (isSaved) {
            saved.update((value) {
              saved.remove(pair);
            });
          } else {
            saved.update((value) {
              saved.add(pair);
            });
          }
        }
      );
    });
  }

  /// Note: Routing is out of scope of this example app.
  void _pushSaved(BuildContext context) {
    Navigator.of(context).push(
        SavedWordsRoute()
    );
  }

  void _toggleTextTransformation() {
    final allCases = TextTransformation.values;
    final transformation = _sharedState.transformation;
    final nextIndex = (allCases.indexOf(transformation.value) + 1) % allCases.length;
    transformation.value = allCases[nextIndex];
  }
}

extension Transformation on WordPair {
  String transformed(TextTransformation transformation) {
    switch (transformation) {
      case TextTransformation.UPPERCASE:
        return this.asUpperCase;
      default:
        return this.asPascalCase;
    }
  }
}

extension Colored on ConnectivityStatus {
  Color get color {
    switch (this) {
      case ConnectivityStatus.DISCONNECTED:
        return Colors.orangeAccent;
      default:
        return Colors.blue;
    }
  }
}

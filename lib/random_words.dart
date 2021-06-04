import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/saved_words.dart';
import 'package:flutter_startup_namer/services/connectivity_service.dart';
import 'package:flutter_startup_namer/state/name.dart';
import 'package:get/get.dart';

class RandomWords extends StatefulWidget {
  final ConnectivityService _connectivityService;

  const RandomWords({ Key? key, required ConnectivityService connectivityService })
      : _connectivityService = connectivityService,
        super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState(_connectivityService);
}

class _RandomWordsState extends State<RandomWords> {
  final ConnectivityService _connectivityService;
  final _sharedState = Get.put(NameState(), permanent: true);

  final List<WordPair> _suggestions = <WordPair>[];
  ConnectivityStatus _connectivityStatus;

  _RandomWordsState(ConnectivityService connectivityService)
      : _connectivityService = connectivityService,
        _connectivityStatus = connectivityService.status,
        super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        leading: IconButton(icon: Icon(Icons.swap_vert), onPressed: _toggleTextTransformation,),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved,),
          IconButton(icon: Icon(Icons.network_cell), onPressed: () => _checkConnection(),)
        ],
        backgroundColor: _connectivityStatus.color,
      ),
      body: _buildSuggestions(),
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

  void _pushSaved() {
    Navigator.of(context).push(
        // FIXME
        SavedWordsRoute(_sharedState.saved)
    );
  }

  void _toggleTextTransformation() {
    final allCases = TextTransformation.values;
    final transformation = _sharedState.transformation;
    final nextIndex = (allCases.indexOf(transformation.value) + 1) % allCases.length;
    transformation.value = allCases[nextIndex];
  }

  void _checkConnection() {
    _connectivityService.checkConnection((status) =>
        setState(() {
          _connectivityStatus = status;
        })
    );
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

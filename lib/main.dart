import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_startup_namer/connectivity_service.dart';

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

enum TextTransformation {
  UPPERCASE,
  NONE
}

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

  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  TextTransformation _transformation = TextTransformation.NONE;
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
          backgroundColor: _connectivityService.status.color,
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
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final isSaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.transformed(_transformation)
      ),
      trailing: Icon(
        isSaved ? Icons.favorite : Icons.favorite_border,
        color: isSaved ? Colors.red : null
      ),
      onTap: () {
        setState(() {
          if (isSaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      }
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      SavedWordsRoute(_saved)
    );
  }

  void _toggleTextTransformation() {
    setState(() {
      final allCases = TextTransformation.values;
      final nextIndex = (allCases.indexOf(_transformation) + 1) % allCases.length;
      _transformation = allCases[nextIndex];
    });
  }

  void _checkConnection() {
    _connectivityService.checkConnection(
        (status) => setState(() {
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
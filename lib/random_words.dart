import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_startup_namer/saved_words.dart';
import 'package:flutter_startup_namer/services/connectivity_service.dart';
import 'package:flutter_startup_namer/services/name_data_service.dart';
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

  /// Data services are accessed the same way as other services. Usage is the same.
  /// The difference is in initialization and purpose.
  /// They are created outside by a factory every time they are queried by Get.find(),
  /// which is what we want. Of course, it is assumed that instances of the same
  /// data service are backed by the same storage and are synchronized properly
  /// for concurrent access. External init allows mocks to be injected for testing.
  /// Init by factory gives advantage of retaining the resources only when needed.
  final NameDataService _dataService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Name Generator'),
            Obx(() => Icon(_connectivityService.status.value.icon)),
          ],
        ),
        leading: IconButton(icon: Icon(Icons.swap_vert), onPressed: _toggleTextTransformation,),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: () => _pushSaved(context),),
          IconButton(icon: Icon(Icons.network_cell), onPressed: () => _connectivityService.checkConnection(),)
        ],
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
        return _buildRow(_dataService.suggestionAt(index), _sharedState.transformation, _sharedState.saved);
      },
    );
  }

  /// It's ok (and even more transparent) to send reactive streams rather than
  /// the whole state down the hierarchy. It's a preferred way within, let's say,
  /// one screen or a complex part of a screen.
  /// (So Main widget/Route fetches the state via GetX and passes down reactive
  /// streams via params to children.)
  Widget _buildRow(WordPair pair, Rx<TextTransformation> transformation, RxSet<WordPair> saved) {
    /// Optimization: It is important to use reactive values inside Obx(), change
    /// of which should actually cause a redraw.
    /// Examine 'saved', for example. 'saved' changes every time any item is saved
    /// or removed, but we don't need to redraw all rows. Only the one affected by
    /// the change. So we derive a simple Boolean for the word pair that represents
    /// the row and use that instead. That doesn't change as often as 'saved'.
    /// Furthermore the toggle action shouldn't cause any change directly (only
    /// change in state that we already listen to), so it's defined outside of Obx().

    // TODO: Write a utility for convenient mapping of Rx values.
    final isSavedStream = saved.subject.stream.map((pairs) => pairs.contains(pair));
    final currentValue = saved.contains(pair);
    final isSaved = currentValue.obs
                    // There's a flag 'firstRebuild' inside the Rx object, which forces
                    // re-emitting an event with the same value, which causes unnecessary
                    // redraw. trigger() clears that flag, so only unique values are
                    // truly emitted.
                    ..trigger(currentValue)
                    ..bindStream(isSavedStream);

    final toggle = () {
      if (isSaved.value) {
        saved.remove(pair);
      } else {
        saved.add(pair);
      }
    };

    return Obx(() {
      print('Render row ${pair.asPascalCase}');
      return ListTile(
        title: Text(
            pair.transformed(transformation.value)
        ),
        trailing: Icon(
            isSaved.value ? Icons.favorite : Icons.favorite_border,
            color: isSaved.value ? Colors.red : null
        ),
        onTap: toggle,
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
  IconData get icon {
    switch (this) {
      case ConnectivityStatus.DISCONNECTED:
        return Icons.no_cell;
      default:
        return Icons.settings_cell;
    }
  }

  Color get color {
    switch (this) {
      case ConnectivityStatus.DISCONNECTED:
        return Colors.orangeAccent;
      default:
        return Colors.blue;
    }
  }
}

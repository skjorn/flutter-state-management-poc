import 'package:english_words/english_words.dart';

/// Data services are Services that accept and provide data. That's their main purpose.
/// They can be backed up by all kinds of storage: local database, user defaults,
/// remote API, file system... Coordination of caching layer and API service happens
/// here. Also how to cache is decided here. Consumers simply retrieve and submit
/// data. All the details are abstracted away.
/// Data services that work with server APIs will often cooperate with Repositories
/// for offline storage. (Not in scope of example.) Repository is a local database
/// that works with a single type of entity, e.g. UserRepository.
class NameDataService {
  final _names = <int, WordPair>{};

  WordPair suggestionAt(int index) {
    if (!_names.containsKey(index)) {
      _names[index] = generateWordPairs().first;
    }
    return _names[index]!;
  }
}
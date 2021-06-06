import 'package:english_words/english_words.dart';
import 'package:flutter_startup_namer/utils/persistence.dart';
import 'package:get/get.dart';
import 'package:dartlin/dartlin.dart';

enum TextTransformation {
  UPPERCASE,
  NONE
}

// TODO: Enum (de)serialization is not future-proof, but for the sake of example enough.
class TextTransformationSerializer implements PersistableSerializer<TextTransformation> {
  @override
  TextTransformation deserialize(dynamic fromValue) => TextTransformation.values[fromValue as int];

  @override
  dynamic serialize(TextTransformation value) => value.index;
}

class NameState {
  late final Rx<TextTransformation> transformation;
  final RxSet<WordPair> saved;

  // Serialization related
  static const _className = "NameState";
  final String? _instanceKey;
  String get _persistenceKey => [_className, _instanceKey].filterNotNull().join('.');

  NameState({
    String? key,
    TextTransformation transformation = TextTransformation.NONE,
    Set<WordPair> saved = const {},
  })
      : saved = saved.obs
      , _instanceKey = key
  {
    final persistor = Persistor(_persistenceKey);
    this.transformation = persistor.persist(
        'transformation',
        transformation,
        serializer: TextTransformationSerializer()
    );
  }
}

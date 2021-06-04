import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

enum TextTransformation {
  UPPERCASE,
  NONE
}

class NameState {
  final Rx<TextTransformation> transformation;
  final RxSet<WordPair> saved;

  NameState({
    TextTransformation transformation = TextTransformation.NONE,
    Set<WordPair> saved = const {},
  })
      : transformation = transformation.obs
      , saved = saved.obs;
}

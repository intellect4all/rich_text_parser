import 'dart:developer';

import 'package:flutter/material.dart';

class RichTextParser extends StatelessWidget {
  final RichTextParserParams params;
  const RichTextParser({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final parsedList = params.getParsedList;
    return RichText(
      text: TextSpan(
        text: parsedList.first['string'] + ' ',
        style: TextStyle(
          fontSize: 14,
          fontWeight:
              parsedList.first['bolden'] ? FontWeight.w700 : FontWeight.normal,
          color: Colors.black,
        ),
        children: parsedList
            .skip(1)
            .map(
              (e) => TextSpan(
                text: e == parsedList.last ? e['string'] : e['string'] + ' ',
                style: TextStyle(
                  fontWeight: e['bolden'] ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            )
            .toList(),
      ),
      // textAlign: TextAlign.center,
    );
  }
}

class RichTextParserParams {
  final String text;
  RichTextParserParams({
    required this.text,
  });

  List<Map<String, dynamic>> get getParsedList {
    final list = text.split(' ');

    // expecting a list of Map {'string':String,'bolden':bool,}
    List<Map<String, dynamic>> first(
        List<String> texts, List<Map<String, dynamic>> currentParsed) {
      // create a scoped copy of the current parsed list
      final parsed = <Map<String, dynamic>>[...currentParsed];

      Map<String, dynamic> parseAndIndex() {
        if (texts.first.startsWith('*') && texts.first.endsWith('*')) {
          return {
            'data': {'string': texts.first.stripAsterisk(), 'bolden': true},
            'index': 1
          };
        }

        if (texts.first.startsWith('*')) {
          // check the next closing * or return a concatenation of the rest of the list
          final text =
              texts.firstWhere((element) => element.endsWith('*'), orElse: () {
            return texts.join(' ');
          });

          final index = texts.indexOf(text);
          if (index != -1) {
            final strings = texts.getRange(0, index + 1).join(' ');

            return {
              'data': {'string': strings.stripAsterisk(), 'bolden': true},
              'index': texts.indexOf(text) + 1
            };
          } else {
            log('this $text');
            return {
              'data': {'string': text, 'bolden': false},
              'index': texts.length
            };
          }
        }

        return {
          'data': {
            'string': texts.first,
            'bolden': false,
          },
          'index': 1
        };
      }

      if (texts.isEmpty) return currentParsed;
      final head = texts.first;
      if (head.contains('*')) {
        final parse = parseAndIndex();
        parsed.add(parse['data']);
        return first(
            texts.getRange(parse['index'], texts.length).toList(), parsed);
      } else {
        if (parsed.isEmpty) {
          parsed.add({'string': head, 'bolden': false});
          return first(texts.skip(1).toList(), parsed);
        }
        final last = parsed.last;
        if (!last['bolden']) {
          last['string'] = '${last['string']} $head';
          parsed[parsed.length - 1] = last;
        } else {
          parsed.add({'string': head, 'bolden': false});
        }
        return first(texts.skip(1).toList(), parsed);
      }
    }

    return first(list, []);
  }
}

extension StringManipulation on String {
  String stripAsterisk() {
    try {
      return substring(1, length - 1);
    } catch (e) {
      return this;
    }
  }
}

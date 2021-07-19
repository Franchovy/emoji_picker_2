import 'package:flutter/material.dart';

class EmojiColorPicker extends StatelessWidget {
  EmojiColorPicker(this.emoji);

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Text(emoji),
          Text(emoji + "🏻"),
          Text(emoji + "🏼"),
          Text(emoji + "🏽"),
          Text(emoji + "🏾"),
          Text(emoji + "🏿")
        ],
      ),
    );
  }
}

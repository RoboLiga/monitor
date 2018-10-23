import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:sodnik/game.dart';

Future<void> main() async {
  String gameJsonString = await HttpRequest.getString('game_example.json');

  Game game = Game.fromJson(json.decode(gameJsonString));

  CanvasElement gameCanvas = querySelector('#game_display');

  // Set canvas resolution to actual in-browser size.
  gameCanvas
    ..width = gameCanvas.offsetWidth
    ..height = gameCanvas.offsetHeight;

  // Calculate the scale so the field fits on the canvas.
  final num scale = min(gameCanvas.width / game.field.width,
      gameCanvas.height / game.field.height);

  game.draw(gameCanvas.context2D, scale);
}

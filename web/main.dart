import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:sodnik/game.dart';

CanvasElement gameCanvas = querySelector('#game_display');
HtmlElement time = querySelector('#time');
HtmlElement team1 = querySelector('#team1');
HtmlElement team2 = querySelector('#team2');

ImageElement logo = ImageElement(src:"Roboliga2019-logo-monitor.svg");

Future<void> main() async {
//  HttpRequest.getString('game_example_server.json').then((jsonf) { Game game = Game.fromJson(json.decode(jsonf));});

  fetch(null);
}

Future<void> fetch(_) async {
  new Timer(new Duration(milliseconds: 10), () {
//    HttpRequest.getString('game_example_new.json').then(refresh).then(fetch);
    HttpRequest.getString('game.json').then(refresh).then(fetch);
  });
}

Future<void> refresh(String gameJsonString) async {
  Game game = Game.fromJson(json.decode(gameJsonString));

  time.text =
      '${game.timeLeftDuration.toString().substring(3,10)}';
  team1.querySelector('.teamName').text = game.team1.name != "" ? game.team1.name : "ime prve ekipe 1";
  team1.querySelector('.teamScore').text = game.team1.score.toString();
  team1.querySelector('.teamId').text = game.team1.id.toString();

  team2.querySelector('.teamName').text = game.team2.name != "" ? game.team2.name : "ime driuge ekipe 1231";
  team2.querySelector('.teamScore').text = game.team2.score.toString();
  team2.querySelector('.teamId').text = game.team2.id.toString();

  // Set canvas resolution to actual in-browser size.
  gameCanvas
    ..width = gameCanvas.offsetWidth
    ..height = gameCanvas.offsetHeight;

  // Calculate the scale so the field fits on the canvas.
  final num scale = min(gameCanvas.width / game.field.width,
      gameCanvas.height / game.field.height);

  game.draw(gameCanvas.context2D, scale, gameCanvas.width, gameCanvas.height, logo);
}

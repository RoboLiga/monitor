import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';

import 'package:sodnik/game.dart';

import 'control_setup.dart';

CanvasElement gameCanvas = querySelector('#game_display');
HtmlElement time = querySelector('#time');
HtmlElement team1 = querySelector('#team1');
HtmlElement team2 = querySelector('#team2');

HtmlElement gameidElement = querySelector("#gameid");

ImageElement logo = ImageElement(src:"/Roboliga2020-logo-monitor.svg");

RegExp gameUrlDecode = new RegExp("/game/([a-f0-9]{4})");

Future<void> main() async {
  controlSetup();

  Match gameMatch = gameUrlDecode.firstMatch(window.location.href);

  if(gameMatch != null) {
    gameidElement.innerHtml = gameMatch.group(1);
  }
//  HttpRequest.getString('game_example_server.json').then((jsonf) { Game game = Game.fromJson(json.decode(jsonf));});

  fetch(null);
}

Future<void> fetch(_) async {
  new Timer(new Duration(milliseconds: 10), () {
//    HttpRequest.getString('game_example_new.json').then(refresh).then(fetch);
    String gameid = gameidElement.innerHtml.trim();
    if(gameid != "") {
      HttpRequest.getString('/game/' + gameid).then(refresh).then(fetch);
    }
    else {
      fetch(_);
    }
//    HttpRequest.getString('game_example_server.json').then(refresh).then(fetch);
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
  final num scale = min(gameCanvas.width / game.fields.field.width,
      gameCanvas.height / game.fields.field.height);

  game.draw(gameCanvas.context2D, scale, gameCanvas.width, gameCanvas.height, logo);
}

import 'dart:convert';
//import 'dart:io';
import 'dart:html';

import 'package:sodnik/game.dart';
import "package:test/test.dart";


@TestOn("browser")

void main() {
  test("Game JSON parses", () async {
    String jsonString = await HttpRequest.getString('web/game_example.json');
    Game game = Game.fromJson(json.decode(jsonString));
    return game;
  });
}

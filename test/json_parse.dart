import 'dart:convert';
//import 'dart:io';
import 'dart:html';

import 'package:sodnik/game.dart';
import "package:test/test.dart";


@TestOn("chrome")

void main() {
  test("Game JSON parses", () async {

    String jsonString = await HttpRequest.getString('../web/game_example_server.json');

    Game game = Game.fromJson(json.decode(jsonString));

    expect(game.game_on, equals(false));
    expect(game.timeLeft, equals(100));
    print(game.robots.first.direction);
    print(game.apples.first.direction);
    print(game.fields.zones.team1.bottomEdge);

    return game;
  });
}


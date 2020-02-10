import 'dart:html';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

/// Glavni objekt, ki opisuje igro in veže skupaj polje in igralce. Prav tako
/// predstavlja začetno točko za risanje.
@JsonSerializable()
class Game {
  /// Trenutni rezultat
  List<int> score;

  /// Ali je igra v teku
  bool game_on;

  /// Preostali čas tekme v sekundah
  double timeLeft;

  Duration get timeLeftDuration => new Duration(
      seconds: timeLeft.toInt(),
      milliseconds: ((timeLeft % 1.0) * 1000).toInt());

  Team team1;
  Team team2;

  /// Opis igralnega polja
  Field field;

  List<Apple> apples;

  /// Seznam botov v igri
  List<Bot> robots;

  /// Privzeti konstruktor
  ///
  /// Za konstrukcijo potrebuje objekt, ki opisuje igralno polje [field] in
  /// seznam botov [robots].
  Game(this.field, this.robots, this.apples, this.timeLeft, this.team1,
      this.team2);

  /// JSON konstruktor
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$GameToJson(this);

  /// Postopek za risanje igre
  ///
  /// Za risanje potrebuje [context], ki je 2D kontekst HTML gradnika *canvas*
  /// in [scale], faktor spreminjanja velikosti.
  ///
  /// Faktor velikosti se izračuna kot manjše od razmerij velikosti med
  /// gradnikom *canvas* in igralnega polja: `min(c_width/f_width,
  /// c_height/f_height)`.
  void draw(CanvasRenderingContext2D context, num scale, int canvasWidth, int canvasHeight, ImageElement logo) {
//    print(context.canvas.width);
//    print(field.width * scale);
//    print((context.canvas.width - field.width * scale * 0.9) * 0.5 * 0.9);

    context
      ..scale(scale * 0.9, scale * 0.9)
//      ..scale(scale, scale)
//      ..translate(field.width * 0.1 * 0.5, field.height * 0.1 * 0.5)
      ..translate((context.canvas.width - field.width * scale * 0.9)/scale * 0.5/0.9,
          (context.canvas.height - field.height * scale * 0.9)/scale * 0.5/0.9)
      ..transform(1, 0, 0, -1, 0, 0)

      ..translate(0, -field.height);
//      ..translate(-field.leftEdge, -field.bottomEdge);

    field._draw(context, logo);

    for (Apple a in apples) {
      a._draw(context, -field.topLeft[0], -field.topLeft[1]);
    }

    for (Bot b in robots) {
      b._draw(
          context, -field.topLeft[0], -field.topLeft[1], team1.id, team2.id);
    }
  }
}

@JsonSerializable()
class Team {
  int id;
  String name;
  int score;

  Team(this.id, this.name, this.score);

  /// JSON konstruktor
  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$TeamToJson(this);
}

/// Opisuje 'nežive' dele igralnega polja.
///
/// Vsebuje širino in višino polja (tla), ter ciljna področja, predmete, itd.
///
/// Koordinate imajo izhodišče v zgornjem levem kotu. Koordinata x narašča na
/// desno; koordinata y narašča navzdol.
@JsonSerializable()
class Field {
  /// Privzeti konstruktor
  ///
  /// TODO: Update doc
  ///
  /// Konstruira igralno polje z levim zgornjim kotom [topLeft] in desnim
  /// spodnjim kotom [bottomRight] na katerem so jabolka podana v seznamu
  /// [apples].
  Field(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight,
      this.baskets);

  /// JSON konstruktor
  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  /// Koordinate zgornjega levega kota igrišča
  List<int> topLeft;
  List<int> topRight;

  List<int> bottomLeft;

  /// Koordinate spodnjega desnega kota igrišča
  List<int> bottomRight;

  int get leftEdge => min(topLeft[0], bottomLeft[0]);

  int get rightEdge => max(topRight[0], bottomRight[0]);

  int get topEdge => max(topLeft[1], topRight[1]);

  int get bottomEdge => min(bottomLeft[1], bottomRight[1]);

  /// Širina igralne površine
  int get width => rightEdge - leftEdge;

  /// Višina igralne površine
  int get height => topEdge - bottomEdge;

  /// Seznam jabolk na igralni površini
//  List<Apple> apples;

  /// Seznam košar
  Map<String, Basket> baskets;

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$FieldToJson(this);

  void _draw(CanvasRenderingContext2D context, ImageElement logo) {
    context
      ..strokeStyle = 'green'
      ..fillStyle = '#E1FFD9'
      ..lineWidth = 10
      ..beginPath()
      ..moveTo(topLeft[0], topLeft[1])
      ..lineTo(topRight[0], topRight[1])
      ..lineTo(bottomRight[0], bottomRight[1])
      ..lineTo(bottomLeft[0], bottomLeft[1])
      ..lineTo(topLeft[0], topLeft[1])
      ..stroke()
      ..fill();

    context
      ..drawImage(logo, width/2-logo.width/2, height/2-logo.height/2);

//      ..strokeRect(0, 0, width, height);

    baskets['team1']._draw(context, -topLeft[0], -topLeft[1], 0);
    baskets['team2']._draw(context, -topLeft[0], -topLeft[1], 1);
  }
}

/// Opisuje košaro; ciljno območje za jabolka.
///
/// Vsebuje širino in višino košare ter identifikator njene ekipe.
///
/// Koordinate imajo izhodišče v zgornjem levem kotu. Koordinata x narašča na
/// desno; koordinata y narašča navzdol.
@JsonSerializable()
class Basket {
  /// Privzeti konstruktor
  ///
  /// Konstruira košaro z levim zgornjim kotom [topLeft] in desnim spodnjim
  /// kotom [bottomRight] ter identifikatorjem ekipe [team].
  Basket(this.topLeft, this.bottomRight);

  /// JSON konstruktor
  factory Basket.fromJson(Map<String, dynamic> json) => _$BasketFromJson(json);

  /// Koordinate zgornjega levega kota košare
  List<int> topLeft;
  List<int> topRight;

  List<int> bottomLeft;

  /// Koordinate spodnjega desnega kota košare
  List<int> bottomRight;

  static const List<String> _idColors = <String>['blue', 'red'];
  static const List<String> _idColorsFill = <String>['#CCF', '#FAA'];

  void _draw(CanvasRenderingContext2D context, int offsetX, int offsetY, team) {
    context
      ..strokeStyle = _idColors[team]
      ..lineWidth = 10
      ..fillStyle = _idColorsFill[team]
//      ..translate(offsetX, offsetY)
      ..beginPath()
      ..moveTo(topRight[0], topRight[1])
      ..lineTo(bottomRight[0], bottomRight[1])
      ..lineTo(bottomLeft[0], bottomLeft[1])
      ..lineTo(topLeft[0], topLeft[1])
      ..lineTo(topRight[0], topRight[1])
      ..stroke()
      ..fill();
//      ..translate(-offsetX, -offsetY);
  }
}

/// Naštevni tip za barve jabolk
enum AppleColor {
  /// Rdeča barva – zdravo
  appleGood,

  /// Rjava barva – gnilo
  appleBad
}

/// Razred, ki predstavlja jabolka.
@JsonSerializable()
class Apple {
  int id;

  /// Barva jabolka
  AppleColor type;

  /// Horizontalna lega jabolka
  int get x => position[0];

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
  int get y => position[1];

  List<int> position;

  double direction;

  /// Privzeti konstruktor
  ///
  /// Jabolko ima barvo [color] in lokacijo [x], [y]. Koordinata [y] narašča od
  /// zgoraj navzdol, torej predstavlja odmik od zgorjnega roba igrišča.
  Apple(this.id, this.type, this.position, this.direction);

  /// JSON konstruktor
  factory Apple.fromJson(Map<String, dynamic> json) => _$AppleFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$AppleToJson(this);

  /// Velikost za namen risanja
  static const num _appleSize = 100;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, int offsetX, int offsetY) {
//    print(direction);
    context
      ..translate(x, y)
      ..rotate(direction * pi / 180)
      ..strokeStyle = type == AppleColor.appleGood ? 'green' : 'brown'
      ..fillStyle = type == AppleColor.appleGood ? 'green' : 'brown'
      ..fillRect(-_appleSize / 2, -_appleSize / 2, _appleSize, _appleSize)
      ..rotate(-direction * pi / 180)
      ..translate(-x, -y);
  }
}

/// Razred, ki opisuje bota.
@JsonSerializable()
class Bot {
  /// Identifikacijska številka
  int id;

  /// Horizontalna lega jabolka
  int get x => position[0];

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
  int get y => position[1];

  List<int> position;

  /// Rotacija bota v stopinjah
  double direction;

  /// Privzeti konstruktor
  ///
  /// Za opis robota potrebuje identifikacijsko številko [id], ekipo bota
  /// [team], poziciji [x] in [y], ter orientacijo/rotacijo bota [direction].
  ///
  /// Ekipa predstavlja identifikator ekipe za katero bot igra. Npr. v 1-1 tekmi
  /// ima en bot `team = 0` in drugi `team = 1`. V 2-2 tekmi imata dva robota
  /// `team = 0` in druga dva `team = 1`.
  ///
  /// Koordinata [y] narašča od
  /// zgoraj navzdol, torej predstavlja odmik od zgorjnega roba igrišča.
  Bot(this.id, this.position, this.direction)
      : assert(direction >= -180 && direction < 180);

  /// JSON konstruktor
  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$BotToJson(this);

  /// Velikost za namen risanja
  static const num _botSize = 100;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, int offsetX, int offsetY,
      int team1id, int team2id) {
    String color;
    if (this.id == team1id) {
      color = 'blue';
    } else if (this.id == team2id) {
      color = 'red';
    } else {
      color = 'black';
    }

    String color2;
    if (this.id == team1id) {
      color2 = '#9999FF';
    } else if (this.id == team2id) {
      color2 = '#FF9999';
    } else {
      color2 = 'white';
    }

    context
      ..strokeStyle = 'black'

      // Translate to bot location and rotate to simplify the drawing procedure
      ..translate(x, y)
      // Canvas rotates clockwise for some reason
      ..rotate(direction * pi / 180)

      // Beak
      ..beginPath()
      ..fillStyle = color
      ..moveTo(_botSize / 2, -_botSize / 2)
      ..lineTo(_botSize, 0)
      ..lineTo(_botSize / 2, _botSize / 2)
      ..fill()

      // Bot body
      ..beginPath()
      ..fillStyle = color2
      ..lineWidth = 10
      ..rect(-_botSize / 2, -_botSize / 2, _botSize, _botSize)
      ..fill()
      ..stroke()

      // Unrotate before id
      ..rotate(-direction * pi / 180)
      // Unmirror
      ..transform(1, 0, 0, -1, 0, 0)

      // Bot id
      ..beginPath()
      ..fillStyle = 'black'
      ..textAlign = 'center'
      ..textBaseline = 'middle'
      ..font = '50pt monospace'
      // Offset for non-central font. 0.2 is a magic number.
      ..fillText(id.toString(), 0, 10)

      // Inverse transform
      ..transform(1, 0, 0, -1, 0, 0)
      ..translate(-x, -y);
  }
}

/// Razred, ki opisuje koordinate
///
/// Koordinate imajo izhodišče v zgornjem levem kotu. Koordinata x narašča na
/// desno; koordinata y narašča navzdol.
@JsonSerializable()
class Position {
  /// Koordinati
  double x, y;

  /// Privzeti konstruktor
  ///
  /// Koordinate imajo izhodišče v zgornjem levem kotu. Koordinata [x] narašča
  /// na desno; koordinata [y] narašča navzdol.
  Position(this.x, this.y) : assert(x >= 0 && y >= 0);

  /// JSON konstruktor
  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$PositionToJson(this);
}

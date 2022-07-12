import 'dart:html';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

/// Glavni objekt, ki opisuje igro in veže skupaj polje in igralce. Prav tako
/// predstavlja začetno točko za risanje.
@JsonSerializable()
class Game {
  String id = "a";

  Fields fields;
  Objects objects;
  Map<String, Team> teams;

  /// Ali je igra v teku
  @JsonKey(name: "gameOn")
  bool game_on;

  /// Preostali čas tekme v sekundah
  double timeLeft;

  Duration get timeLeftDuration => new Duration(
      seconds: timeLeft.toInt(),
      milliseconds: ((timeLeft % 1.0) * 1000).toInt());


  Game(this.id, this.fields, this.objects, this.teams, this.game_on,
      this.timeLeft);

  Team get team1 => teams["team1"];
  Team get team2 => teams["team2"];

  List<Bot> get robots => objects.robots.values.toList();
  List<Apple> get apples => objects.hives.values.toList();

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
    context
      ..scale(scale * 0.9, scale * 0.9)
      ..translate((context.canvas.width - fields.field.width * scale * 0.9)/scale * 0.5/0.9,
          (context.canvas.height - fields.field.height * scale * 0.9)/scale * 0.5/0.9)
      ..transform(1, 0, 0, -1, 0, 0)
      ..translate(0, -fields.field.height);

    fields._draw(context, logo);

    for (Apple a in apples) {
      a._draw(context, -fields.field.topLeft.x, -fields.field.topLeft.y);
    }

    for (Bot b in robots) {
      b._draw(
          context, -fields.field.topLeft.x, -fields.field.topLeft.y, team1.id, team2.id);
    }
  }
}

@JsonSerializable()
class Objects {
  Map<String, Apple> hives;
//  List<dynamic> hives;
  Map<String, Bot> robots;
//  List<dynamic> robots;

  Objects(this.hives, this.robots);


  /// JSON konstruktor
  factory Objects.fromJson(Map<String, dynamic> json) => _$ObjectsFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$ObjectsToJson(this);
}

@JsonSerializable()
class Fields {
  Field field;
  Map<String, Basket> baskets;
  Zones zones;

  Fields(this.field, this.baskets, this.zones);

  /// JSON konstruktor
  factory Fields.fromJson(Map<String, dynamic> json) => _$FieldsFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$FieldsToJson(this);

  void _draw(CanvasRenderingContext2D context, ImageElement logo) {
    field._draw(context, logo);

    baskets['team1']._draw(context, -field.topLeft.x, -field.topLeft.y, 0);
    baskets['team2']._draw(context, -field.topLeft.x, -field.topLeft.y, 1);

    zones._draw(context, -field.topLeft.x, -field.topLeft.y);
  }
}

@JsonSerializable()
class Zones {
  Zones(this.team1, this.team2, this.neutral);

  Zone team1;
  Zone team2;
  Zone neutral;

  factory Zones.fromJson(Map<String, dynamic> json) => _$ZonesFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$ZonesToJson(this);

  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY) {
    team1._draw(context, offsetX, offsetY, 0);
    team2._draw(context, offsetX, offsetY, 1);
    neutral._draw(context, offsetX, offsetY, 2);
  }
}

@JsonSerializable()
class Zone {


  Position topLeft;
  Position topRight;

  Position bottomLeft;

  /// Koordinate spodnjega desnega kota igrišča
  Position bottomRight;

  double get leftEdge => min(topLeft.x, bottomLeft.x);

  double get rightEdge => max(topRight.x, bottomRight.x);

  double get topEdge => max(topLeft.y, topRight.y);

  double get bottomEdge => min(bottomLeft.y, bottomRight.y);


  /// Širina igralne površine
  double get width => rightEdge - leftEdge;

  /// Višina igralne površine
  double get height => topEdge - bottomEdge;

  Zone(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);

  factory Zone.fromJson(Map<String, dynamic> json) => _$ZoneFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$ZoneToJson(this);

//  static const List<String> _idColors = <String>['blue', 'red',];
  static const List<String> _idColorsFill = <String>['#CCF9', '#FAA9', '#AFA9'];

  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY, team) {
    context
//      ..strokeStyle = _idColors[team]
      ..fillStyle = _idColorsFill[team]
      ..beginPath()
      ..moveTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..lineTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..closePath()
      ..fill();
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
  Field(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);

  /// JSON konstruktor
  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  /// Koordinate zgornjega levega kota igrišča
  Position topLeft;
  Position topRight;

  Position bottomLeft;

  /// Koordinate spodnjega desnega kota igrišča
  Position bottomRight;

  double get leftEdge => min(topLeft.x, bottomLeft.x);

  double get rightEdge => max(topRight.x, bottomRight.x);

  double get topEdge => max(topLeft.y, topRight.y);

  double get bottomEdge => min(bottomLeft.y, bottomRight.y);

  /// Širina igralne površine
  double get width => rightEdge - leftEdge;

  /// Višina igralne površine
  double get height => topEdge - bottomEdge;

  /// Seznam jabolk na igralni površini
//  List<Apple> apples;

  /// Seznam košar
//  Map<String, Basket> baskets;

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$FieldToJson(this);

  void _draw(CanvasRenderingContext2D context, ImageElement logo) {
    context
      ..strokeStyle = 'green'
      ..fillStyle = '#E1FFD9'
      ..lineWidth = 10
      ..beginPath()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..lineTo(topLeft.x, topLeft.y)
      ..closePath()
      ..stroke()
      ..fill();

    context
      ..drawImage(logo, width/2-logo.width/2, height/2-logo.height/2) ;

//      ..strokeRect(0, 0, width, height);

//    baskets['team1']._draw(context, -topLeft[0], -topLeft[1], 0);
//    baskets['team2']._draw(context, -topLeft[0], -topLeft[1], 1);
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
  Position topLeft;
  Position topRight;

  Position bottomLeft;

  /// Koordinate spodnjega desnega kota košare
  Position bottomRight;

  static const List<String> _idColors = <String>['blue', 'red'];
  static const List<String> _idColorsFill = <String>['#CCF', '#FAA'];

  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY, team) {
    context
      ..strokeStyle = _idColors[team]
      ..lineWidth = 10
      ..fillStyle = _idColorsFill[team]
//      ..translate(offsetX, offsetY)
      ..beginPath()
      ..moveTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..lineTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..closePath()
      ..stroke()
      ..fill();
//      ..translate(-offsetX, -offsetY);
  }
}

/// Naštevni tip za barve jabolk
enum AppleColor {
  /// Rdeča barva – zdravo
  HIVE_HEALTHY,

  /// Rjava barva – gnilo
  HIVE_DISEASED
}

/// Razred, ki predstavlja jabolka.
@JsonSerializable()
class Apple {
  int id;

  /// Barva jabolka
  AppleColor type;

  double get x => position.x;

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
//  int get y => position[1];
//  double y;
  double get y => position.y;
//  List<int> position;
  Position position;

//  List<int> position;
  double dir;
//  double get direction => dir/3.14*180;
  double get direction => dir;

  /// Privzeti konstruktor
  ///
  /// Jabolko ima barvo [color] in lokacijo [x], [y]. Koordinata [y] narašča od
  /// zgoraj navzdol, torej predstavlja odmik od zgorjnega roba igrišča.
  Apple(this.id, this.type, this.position, this.dir);

  /// JSON konstruktor
  factory Apple.fromJson(Map<String, dynamic> json) => _$AppleFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$AppleToJson(this);

  /// Velikost za namen risanja
  static const num _appleSize = 100;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY) {
//    print(direction);
    context
      ..translate(x, y)
      ..rotate(direction * pi / 180)
      ..strokeStyle = type == AppleColor.HIVE_HEALTHY ? 'green' : 'brown'
      ..fillStyle = type == AppleColor.HIVE_HEALTHY ? 'green' : 'brown'
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
//  int get x => position[0];
//  double x;
  double get x => position.x;

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
//  int get y => position[1];
//  double y;
  double get y => position.y;
//  List<int> position;
  Position position;

  /// Rotacija bota v stopinjah
  double dir;
//  double get direction => dir/3.14* 180.0;
  double get direction => dir;

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
  Bot(this.id, this.position, this.dir);

  /// JSON konstruktor
  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$BotToJson(this);

  /// Velikost za namen risanja
  static const num _botSize = 100;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY,
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
  Position(this.x, this.y);

  /// JSON konstruktor
  factory Position.fromJson(Map<String, dynamic> json) =>
      _$PositionFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$PositionToJson(this);
}

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
  double time_left;

  /// Opis igralnega polja
  Field field;

  /// Seznam botov v igri
  List<Bot> bots;

  /// Privzeti konstruktor
  ///
  /// Za konstrukcijo potrebuje objekt, ki opisuje igralno polje [field] in
  /// seznam botov [bots].
  Game(this.field, this.bots);

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
  void draw(CanvasRenderingContext2D context, num scale) {
    context
      ..scale(scale, scale)
    // Outline
      ..strokeStyle = 'green'
      ..lineWidth = 0.1
      ..strokeRect(0, 0, field.width, field.height);

//    for(var i = 0; i < 150; i+=5){
//      context.strokeRect(i, 0, 0.01, 50);
//    }
//
//    for(var j = 0; j < 50; j+=5){
//      context.strokeRect(0, j, 150, 0.01);
//    }

    for (Apple a in field.apples) {
      a._draw(context, -field.top_left.x, -field.top_left.y);
    }

    for (Bot b in bots) {
      b._draw(context, -field.top_left.x, -field.top_left.y);
    }
  }
}

/// Opisuje 'nežive' dele igralnega polja.
///
/// Vsebuje širino in višino polja (tla), ter ciljna področja, predmete, itd.
///
/// Koordinate imajo izhodišče v zgornjem levem kotu. Koordinata x narašča na
/// desno; koordinata y narašča navzdol.
@JsonSerializable()
class Field {
  /// Koordinate zgornjega levega kota igrišča
  Position top_left;

  /// Koordinate spodnjega desnega kota igrišča
  Position bottom_right;

  /// Širina igralne površine
  double get width => bottom_right.x - top_left.x;

  /// Višina igralne površine
  double get height => bottom_right.y - top_left.y;

  /// Seznam jabolk na igralni površini
  List<Apple> apples;

  /// Privzeti konstruktor
  ///
  /// Konstruira igralno polje širine [width] and višine [height] na katerem so
  /// jabolka podana v seznamu [apples].
  Field(this.top_left, this.bottom_right, this.apples)
      : assert(width >= 0 &&
      height >= 0 &&
      top_left.x >= 0 &&
      top_left.y >= 0 &&
      bottom_right.x >= 0 &&
      bottom_right.y >= 0);

  /// JSON konstruktor
  factory Field.fromJson(Map<String, dynamic> json) => _$FieldFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$FieldToJson(this);
}

/// Naštevni tip za barve jabolk
enum AppleColor {
  /// Rdeča barva – zdravo
  red,

  /// Rjava barva – gnilo
  brown
}

/// Razred, ki predstavlja jabolka.
@JsonSerializable()
class Apple {
  /// Barva jabolka
  AppleColor color;

  /// Horizontalna lega jabolka
  double x;

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
  double y;

  /// Privzeti konstruktor
  ///
  /// Jabolko ima barvo [color] in lokacijo [x], [y]. Koordinata [y] narašča od
  /// zgoraj navzdol, torej predstavlja odmik od zgorjnega roba igrišča.
  Apple(this.color, this.x, this.y) : assert(x >= 0 && y >= 0);

  /// JSON konstruktor
  factory Apple.fromJson(Map<String, dynamic> json) => _$AppleFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$AppleToJson(this);

  /// Velikost za namen risanja
  static const num _appleSize = 1;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY) {
    context
      ..strokeStyle = color == AppleColor.red ? 'red' : 'brown'
      ..fillStyle = color == AppleColor.red ? 'red' : 'brown'
      ..fillRect(x - _appleSize / 2 + offsetX, y - _appleSize / 2 + offsetY,
          _appleSize, _appleSize);
  }
}

/// Razred, ki opisuje bota.
@JsonSerializable()
class Bot {
  /// Identifikacijska številka
  int id;

  /// Ekipa bota v večigralski tekmi
  int team;

  /// Horizontalna lega jabolka
  double x;

  /// Vertikalna lega jabolka (NB pozitivne vrednosti predstavljajo odmik od
  /// vrha)
  double y;

  /// Rotacija bota v stopinjah
  double orientation;

  /// Privzeti konstruktor
  ///
  /// Za opis robota potrebuje identifikacijsko številko [id], ekipo bota
  /// [team], poziciji [x] in [y], ter orientacijo/rotacijo bota [orientation].
  ///
  /// Ekipa predstavlja identifikator ekipe za katero bot igra. Npr. v 1-1 tekmi
  /// ima en bot `team = 0` in drugi `team = 1`. V 2-2 tekmi imata dva robota
  /// `team = 0` in druga dva `team = 1`.
  ///
  /// Koordinata [y] narašča od
  /// zgoraj navzdol, torej predstavlja odmik od zgorjnega roba igrišča.
  Bot(this.id, this.team, this.x, this.y, this.orientation)
      : assert(x >= 0 && y >= 0 && orientation >= 0 && orientation < 360);

  /// JSON konstruktor
  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);

  /// JSON vzaporedjevalnik
  Map<String, dynamic> toJson() => _$BotToJson(this);

  /// Velikost za namen risanja
  static const num _botSize = 1.5;

  /// Postopek za risanje
  ///
  /// Za risanje potrebuje 2D [context] HTML gradnika *canvas*.
  void _draw(CanvasRenderingContext2D context, double offsetX, double offsetY) {
    context
      ..strokeStyle = 'black'

      // Translate to bot location and rotate to simplify the drawing procedure
      ..translate(x + offsetX, y + offsetY)
      // Canvas rotates clockwise for some reason
      ..rotate(-orientation * pi / 180)

      // Beak
      ..beginPath()
      ..fillStyle = 'black'
      ..moveTo(_botSize / 2, -_botSize / 2)
      ..lineTo(_botSize, 0)
      ..lineTo(_botSize / 2, _botSize / 2)
      ..fill()

      // Bot body
      ..beginPath()
      ..fillStyle = 'white'
      ..rect(-_botSize / 2, -_botSize / 2, _botSize, _botSize)
      ..fill()
      ..stroke()

      // Bot id
      ..beginPath()
      ..fillStyle = 'black'
      ..textAlign = 'center'
      ..textBaseline = 'middle'
      ..font = '1pt monospace'
      // Offset for non-central font. 0.2 is a magic number.
      ..fillText(id.toString(), 0, 0.2)

      // Inverse transform
      ..rotate(orientation * pi / 180)
      ..translate(-x - offsetX, -y - offsetY);
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

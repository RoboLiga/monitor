import 'dart:html';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

/// Glavni objekt, ki opisuje igro in veže skupaj polje in igralce. Prav tako
/// predstavlja začetno točko za risanje.
@JsonSerializable()
class Game {
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
      a._draw(context);
    }

    for (Bot b in bots) {
      b._draw(context);
    }
  }
}

/// Opisuje 'nežive' dele igralnega polja.
///
/// Vsebuje širino in višino polja (tla), ter ciljna področja, predmete, itd.
@JsonSerializable()
class Field {
  /// Širina igralne površine
  double width;

  /// Višina igralne površine
  double height;

  /// Seznam jabolk na igralni površini
  List<Apple> apples;

  /// Privzeti konstruktor
  ///
  /// Konstruira igralno polje širine [width] and višine [height] na katerem so
  /// jabolka podana v seznamu [apples].
  Field(this.width, this.height, this.apples)
      : assert(width >= 0 && height >= 0);

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
  void _draw(CanvasRenderingContext2D context) {
    context
      ..strokeStyle = color == AppleColor.red ? 'red' : 'brown'
      ..fillStyle = color == AppleColor.red ? 'red' : 'brown'
      ..fillRect(
          x - _appleSize / 2, y - _appleSize / 2, _appleSize, _appleSize);
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
  void _draw(CanvasRenderingContext2D context) {
    context
      ..strokeStyle = 'black'

      // Translate to bot location and rotate to simplify the drawing procedure
      ..translate(x, y)
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
      ..translate(-x, -y);
  }
}

# Sodnik za Robo Ligo

## Opis

Spletna aplikacija, ki v brskalniku prikaže stanje igre.

## Odvisnosti

Za razvoj je uporabljen Dart SDK 2.0.0.

Za razvoj je uporabljen brskalnik Firefox 62.0.3.

## Gradnja

Za gradnjo pripravimo direktorij `build_dir`, ter poženemo  
```
$ pub run build_runner build --output <build_dir>
```

## Strežba

Zgrajeno aplikacijo lahko strežemo s pomočjo poljubnega HTTP strežnika (Apache, nginx).

Aplikacijo je mogoče streči tudi brez gradnje:
```
$ pub global run webdev serve web:8080
```
kjer je aplikacija nato dosegljiva na `http://localhost:8080`.

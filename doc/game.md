Opis Game JSON datoteke
=====================

V tem dokumentu so opisani objekti v datoteki JSON, ki opisuje trenutno stanje igre. Primer celotne datoteke je v `web/game_example.json`.

Igra
----
```
{
  "timeLeft": 100.0,
  "gameOn": true,
  "team1": <Ekipa>,
  "team2": <Ekipa>,
  "field": <Igrišče>,
  "apples": [ <Jabolko>, ... ],
  "robots": [ <Robot>, ...]
}
```

Igra je glavni objekt v datoteki JSON. Vsebuje preostali čas tekme `timeLeft` v sekundah, zastavico, ki opisuje ali je tekma v teku, `gameOn`, opisa ekip `team1` in `team2`, opis igrišča `field`, seznam jabolk na igrišču `apples` in seznam robotov na igrišču `robots`.

Ekipa
-----
```
{
  "id": 13,
  "name": "Drugi team",
  "score": 2
}
```

Ekipa je objekt sestavljen iz identifikatorja ArUco značke njenega robota `id`, imena ekipe `name` in trenutnega števila točk ekipe `score`.

Igrišče
-------------
```
{
  "topLeft": [10, 2],
  "topRight": [150, 2],
  "bottomLeft": [10, 50],
  "bottomRight": [150, 50],
  "baskets": {
    "team1": <Košara>, 
    "team2": <Košara>
  }
}
```

Igrišče je objekt sestavljen iz koordinat vogalov: `topLeft`, `topRight`, `bottomLeft` in `bottomRight`, ter objekta `baskets`, ki vsebuje opisa košar obeh ekip `team1` in `team2`.

Košara
------
```
{
  "topLeft": [10, 10],
  "topRight": [20, 10],
  "bottomLeft": [10, 40],
  "bottomRight": [20, 40]
}
```

Košara je objekt, ki vsebuje štiri točke, ki predstavljajo koordinate njenih vogalov (v milimetrih).

Robot
-----
```
{
  "id": 13,
  "position": [15, 8],
  "orientation": 10
}
```

Robot je objekt sestavljen iz identifikatorja ArUco `id`, pozicije na igralnem polju `position` (v milimetrih) in azimutne orientacije `orientation` (v stopinjah).

Jabolko
-------
```
{
  "type": "appleGood",
  "position": [10, 5]
}
```

Jabolko je objekt sestavljen iz opisa tipa `type`, ki je lahko `appleGood` za zdravo jabolko in `appleBad` za gnilo, in pozicije na igralnem polju `position` (v milimetrih).

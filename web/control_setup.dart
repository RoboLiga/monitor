import 'dart:convert';
import 'dart:html';

Future<void> controlSetup() async {
  setupNewGame();

  setupTime();

  setupScore();

  setupTeams();

  setupStartStop();

  setupSetId();

  setupHideControls();
}

Future<void> setupNewGame() async {
  ButtonElement newGame = querySelector("#new_game_button");

  SelectElement team1Select = querySelector("#team1_select");
  SelectElement team2Select = querySelector("#team2_select");


  newGame.onClick.listen((e) {
    String team1 = team1Select.value;
    String team2 = team2Select.value;

    HttpRequest.request("/game",
        method: "PUT",
        sendData: '{"team1":${team1}, '
            '"team2":${team2}}',
        requestHeaders: <String, String>{
          "Content-Type": "application/json"
        }).then((response) {
      String gameId = json.decode(response.response)["gameId"];

      querySelector("#gameid").innerHtml = gameId;

      window.history.replaceState(null, "", "/game/" + gameId);
    });
//    String gameId = "a123";
//
//    querySelector("#gameid").innerHtml = gameId;
//
//    window.history.replaceState(null, "", "/game/" + gameId);
  });
}

RegExp timeRegex = new RegExp("([0-9]{1,2}):([0-9]{2})");

Future<void> setupTime() async {
  ButtonElement timeSubmit = querySelector("#time_submit");
  InputElement timeInput = querySelector("#time_input");

  timeSubmit.onClick.listen((e) {
    String timeString = timeInput.value;
    print(timeString);

    Match match = timeRegex.firstMatch(timeString);
    print(match);

    double gameTime =
        double.parse(match.group(1)) * 60 + double.parse(match.group(2));

    HttpRequest.request(window.location.pathname + "/time",
        method: "POST", sendData: '{"gameTime":${gameTime}}',
        requestHeaders: <String, String>{
          "Content-Type": "application/json"
        });
  });
}

Future<void> setupScore() async {
  ButtonElement scoreSubmit = querySelector("#score_submit");
  InputElement team1Score = querySelector("#team1_score_adjust");
  InputElement team2Score = querySelector("#team2_score_adjust");

  scoreSubmit.onClick.listen((e) {
    String team1adjustString = team1Score.value;
    String team2adjustString = team2Score.value;
    print(team1adjustString);
    print(team2adjustString);

    HttpRequest.request(window.location.pathname + "/score",
        method: "POST",
        sendData: '{"team1":${team1adjustString}, '
            '"team2":${team2adjustString}}',
        requestHeaders: <String, String>{"Content-Type": "application/json"});
  });
}

Future<void> setupTeams() async {
  ButtonElement submitTeams = querySelector("#teams_submit");
  SelectElement team1Select = querySelector("#team1_select");
  SelectElement team2Select = querySelector("#team2_select");

//  print("a");

  HttpRequest.getString("/teams").then((responseText) {
    List<dynamic> teamsJson = json.decode(responseText);

    print(teamsJson[0]["id"]);

    team1Select.innerHtml = "";
    team2Select.innerHtml = "";

    teamsJson.forEach((team) {
      team1Select.children
          .add(new OptionElement(data: team["name"], value: team["id"]));
      team2Select.children
          .add(new OptionElement(data: team["name"], value: team["id"]));
    });
  });

  submitTeams.onClick.listen((e) {
    String team1 = team1Select.value;
    String team2 = team2Select.value;

    HttpRequest.request(window.location.pathname + "/teams",
        method: "POST",
//        sendData: '{"team1":${int.parse(team1)}, '
//            '"team2":${int.parse(team2)}}');
        sendData: '{"teams":[${int.parse(team1)},${int.parse(team2)}]}',
        requestHeaders: <String, String>{"Content-Type": "application/json"});
  });
}

Future<void> setupStartStop() async {
  ButtonElement start = querySelector("#start_button");
  ButtonElement stop = querySelector("#stop_button");

  start.onClick.listen((e) {
    HttpRequest.request(window.location.toString() + "/start", method: "PUT");
    start.disabled = true;
    stop.disabled = false;
  });
  stop.onClick.listen((e) {
    HttpRequest.request(window.location.toString() + "/stop", method: "PUT");
    stop.disabled = true;
    start.disabled = false;
  });
}

Future<void> setupSetId() async {
  ButtonElement setId = querySelector("#set_game_id_button");

  setId.onClick.listen((e) {
    InputElement newId = querySelector("#set_game_id_input");
    querySelector("#gameid").innerHtml = newId.value;

    window.history.replaceState(null, "", "/game/" + newId.value);
  });
}

Future<void> setupHideControls() async {
  ButtonElement hideButton = querySelector("#hide_controls_button");

  hideButton.onClick.listen((e) {

    querySelector("#controls").style.display = "none";
    querySelector("#gameid").style.display = "none";
  });
}
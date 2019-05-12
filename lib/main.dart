import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Yesterday''s Weather'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Forecast forecast;
  DailyData yesterdaysWeather;
  bool isLoaded = false;

  void loadForecastResults(){
    if(!isLoaded){
      fetchPost()
          .then( (e) => setState((){
              isLoaded = true;
              forecast = e;
              yesterdaysWeather = e.daily.dailyData[0];
          }
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    loadForecastResults();

    if (!isLoaded) {
      //TODO: loading screen
      return new Container();
    }
    else {
      // This method is rerun every time setState is called, for instance as done
      // by the _incrementCounter method above.
      //
      // The Flutter framework has been optimized to make rerunning build methods
      // fast, so that you can just rebuild anything that needs updating rather
      // than having to individually change instances of widgets.
      return Scaffold(
        body: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: findGradientColors(yesterdaysWeather.icon),
            ),
          ),
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                titleDisplay(),
                Expanded(
                  child: Container (
                    child: Column(
                      children: <Widget>[
                        detailsDisplay()[0],//highTempContainer
                        detailsDisplay()[1],//lowTempContainer ],
                      ]
                    ),
                  )
                ),
                Container (
                  color: Color(0xFF333333),
                  child: footerSection,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget footerSection = Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Image(
          image: AssetImage('assets/poweredby-oneline-darkbackground.png'),
          alignment: Alignment.bottomCenter,
      )
    )
  );

  Container titleDisplay() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  yesterdaysWeather.temperatureHigh.toInt().toString() + '°F',
                  style: whiteTextStyle(84)
                ),
              ],
            ),
            Expanded(
              child: new Column(
                children: [
                  findIcon(yesterdaysWeather.icon),
                  summaryDisplay(),
                ],
              ),
            ),
      ]),
    );
  }

  List<Widget> detailsDisplay() {
    List<Container> containers = [];
    var formatter = new DateFormat('h:mm a');
    DateTime highDate = new DateTime.fromMillisecondsSinceEpoch(yesterdaysWeather.temperatureHighTime * 1000);
    DateTime lowDate = new DateTime.fromMillisecondsSinceEpoch(yesterdaysWeather.temperatureLowTime * 1000);
    var highTempTime = formatter.format(highDate);
    var lowTempTime = formatter.format(lowDate);

    Container highTempContainer = Container(
      padding: const EdgeInsets.fromLTRB(32,32,32,0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(FontAwesomeIcons.arrowUp, size: 35, color: Colors.redAccent),
            Text(
                yesterdaysWeather.temperatureHigh.toInt().toString() + '°F at ' + highTempTime,
                style: whiteTextStyle(35)
            ),
          ]),
    );

    containers.add(highTempContainer);

    Container lowTempContainer = Container(
      padding: const EdgeInsets.fromLTRB(32,10,32,0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(FontAwesomeIcons.arrowDown, size: 35, color: Colors.blueGrey),
            Text(
                yesterdaysWeather.temperatureLow.toInt().toString() + '°F at ' + lowTempTime,
                style: whiteTextStyle(35)
            ),
          ]),
    );

    containers.add(lowTempContainer);

    return containers;
  }

  Icon findIcon(String iconString){
      //clear-day, clear-night, rain, snow, sleet, wind, fog, cloudy, partly-cloudy-day, or partly-cloudy-night
      IconData iconData = FontAwesomeIcons.solidSun;
      switch(iconString) {
          case "clear-day": {iconData = FontAwesomeIcons.solidSun;}
          break;
          case "clear-night": {iconData = FontAwesomeIcons.solidMoon;}
          break;
          case "rain": {iconData = FontAwesomeIcons.cloudRain;}
          break;
          case "snow": {iconData = FontAwesomeIcons.snowflake;}
          break;
          case "sleet": {iconData = FontAwesomeIcons.cloudRain;}
          break;
          case "wind": {iconData = FontAwesomeIcons.wind;}
          break;
          case "fog": {iconData = FontAwesomeIcons.cloud;}
          break;
          case "cloudy": {iconData = FontAwesomeIcons.cloud;}
          break;
          case "partly-cloudy-day": {iconData = FontAwesomeIcons.cloudSun;}
          break;
          case "partly-cloudy-night": {iconData = FontAwesomeIcons.cloudMoon;}
          break;

          default: {iconData = FontAwesomeIcons.solidSun;}
          break;
      }

      return Icon(iconData, size: 84, color: Colors.white);
  }

  List<Color> findGradientColors(String iconString){
      List<Color> colors;

      switch(iconString) {
          case "clear-day":
          case "wind": {colors = const <Color>[Colors.blue, Colors.cyan];}
          break;
          case "clear-night":
          case "rain":
          case "snow":
          case "sleet":
          case "fog":
          case "cloudy":
          case "partly-cloudy-day":
          case "partly-cloudy-night": {colors = const <Color>[Colors.blueGrey, Colors.white70];}
          break;
  
          default: {colors = const <Color>[Colors.blue, Colors.cyan];}
          break;
      }

      return colors;
  }

  Widget summaryDisplay() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
            yesterdaysWeather.summary,
            textAlign: TextAlign.center,
            style: whiteTextStyle(12)
        )
    );
  }
}

TextStyle whiteTextStyle(double fontSize){
  return TextStyle(
    color: Colors.white,
    fontSize: fontSize,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(0.5, 0.5),
        blurRadius: 1.0,
        color: Color.fromARGB(255, 0, 0, 0),
      )
    ],
  );
}

Future<Map<String, double>> getLocation() async{
  Map<String, double> currentLocation = new Map<String, double>();

  var location = new Location();
  String error = '';
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    currentLocation = await location.getLocation();
  } catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = 'Permission denied';
    }
    currentLocation = null;
  }

  return currentLocation;
}

Future<Forecast> fetchPost() async {
  var now = new DateTime.now();
  var yesterday = new DateTime(now.year, now.month, now.day -1);
  var formatter = new DateFormat('yyyy-MM-ddThh:mm:ss');

  String darkSkyApiKey = '579a77ae78f5ae084f9d856a3f4b474d';
  String time = formatter.format(yesterday);
  String queryString = '?exclude=currently,minutely,hourly,alerts,flags';

  //get lat/long location from phone
  Map<String, double> location = await getLocation();
  String latitude = location['latitude'].toString();
  String longitude = location['longitude'].toString();

  String url = 'https://api.darksky.net/forecast/' + darkSkyApiKey + '/' + latitude + ',' + longitude + ',' + time + queryString;

  final response =
  await http.get(url);

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return Forecast.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class Forecast{
  final double latitude;
  final double longitude;
  final String timezone;
  final Daily daily;
  final int offset;

  Forecast({this.latitude, this.longitude, this.timezone, this.daily, this.offset});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      daily: Daily.fromJson(json['daily']),
      offset: json['offset'],
    );
  }
}

class Daily{
  final List<DailyData> dailyData;

  Daily({this.dailyData});

  factory Daily.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    print(list.runtimeType); //returns List<dynamic>
    List<DailyData> data = list.map((i) => DailyData.fromJson(i)).toList();

    return Daily(
        dailyData: data
    );
  }

}

///see https://darksky.net/dev/docs#time-machine-request
class DailyData{
  final int time;
  final String summary;
  final String icon;
  final int sunriseTime;
  final int sunsetTime;
  final double moonPhase;
  final double precipIntensity;
  final double precipIntensityMax;
  final int precipIntensityMaxTime;
  final double precipProbability;
  final String precipType;
  final double temperatureHigh;
  final int temperatureHighTime;
  final double temperatureLow;
  final int temperatureLowTime;
  final double apparentTemperatureHigh;
  final int apparentTemperatureHighTime;
  final double apparentTemperatureLow;
  final int apparentTemperatureLowTime;
  final double dewPoint;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double windGust;
  final int windGustTime;
  final int windBearing;
  final double cloudCover;
  final int uvIndex;
  final int uvIndexTime;
  final double visibility;
  final double ozone;
  final double temperatureMin;
  final int temperatureMinTime;
  final double temperatureMax;
  final int temperatureMaxTime;
  final double apparentTemperatureMin;
  final int apparentTemperatureMinTime;
  final double apparentTemperatureMax;
  final int apparentTemperatureMaxTime;

  DailyData({this.time,this.summary,this.icon,this.sunriseTime,this.sunsetTime,this.moonPhase,this.precipIntensity,
    this.precipIntensityMax,this.precipIntensityMaxTime,this.precipProbability,this.precipType,this.temperatureHigh,
    this.temperatureHighTime,this.temperatureLow,this.temperatureLowTime,this.apparentTemperatureHigh,this.apparentTemperatureHighTime,
    this.apparentTemperatureLow,this.apparentTemperatureLowTime,this.dewPoint,this.humidity,this.pressure,this.windSpeed,this.windGust,
    this.windGustTime,this.windBearing,this.cloudCover,this.uvIndex,this.uvIndexTime,this.visibility,this.ozone,this.temperatureMin,
    this.temperatureMinTime,this.temperatureMax,this.temperatureMaxTime,this.apparentTemperatureMin,this.apparentTemperatureMinTime,
    this.apparentTemperatureMax,this.apparentTemperatureMaxTime});

  factory DailyData.fromJson(Map<String, dynamic> json) {

    return DailyData(
      time: json['time'],
      summary: json['summary'],
      icon: json['icon'],
      sunriseTime: json['sunriseTime'],
      sunsetTime: json['sunsetTime'],
      moonPhase: getDoubleFromJson('moonPhase', json),
      precipIntensity: getDoubleFromJson('precipIntensity', json),
      precipIntensityMax: getDoubleFromJson('precipIntensityMax', json),
      precipIntensityMaxTime: json['precipIntensityMaxTime'],
      precipProbability: getDoubleFromJson('precipProbability', json),
      precipType: json['precipType'],
      temperatureHigh: getDoubleFromJson('temperatureHigh', json),
      temperatureHighTime: json['temperatureHighTime'],
      temperatureLow: getDoubleFromJson('temperatureLow', json),
      temperatureLowTime: json['temperatureLowTime'],
      apparentTemperatureHigh: getDoubleFromJson('apparentTemperatureHigh', json),
      apparentTemperatureHighTime: json['apparentTemperatureHighTime'],
      apparentTemperatureLow: getDoubleFromJson('apparentTemperatureLow', json),
      apparentTemperatureLowTime: json['apparentTemperatureLowTime'],
      dewPoint: getDoubleFromJson('dewPoint', json),
      humidity: getDoubleFromJson('humidity', json),
      pressure: getDoubleFromJson('pressure', json),
      windSpeed: getDoubleFromJson('windSpeed', json),
      windGust: getDoubleFromJson('windGust', json),
      windGustTime: json['windGustTime'],
      windBearing: json['windBearing'],
      cloudCover: getDoubleFromJson('cloudCover', json),
      uvIndex: json['uvIndex'],
      uvIndexTime: json['uvIndexTime'],
      visibility: getDoubleFromJson('visibility', json),
      ozone: getDoubleFromJson('ozone', json),
      temperatureMin: getDoubleFromJson('temperatureMin', json),
      temperatureMinTime: json['temperatureMinTime'],
      temperatureMax: getDoubleFromJson('temperatureMax', json),
      temperatureMaxTime: json['temperatureMaxTime'],
      apparentTemperatureMin: getDoubleFromJson('apparentTemperatureMin', json),
      apparentTemperatureMinTime: json['apparentTemperatureMinTime'],
      apparentTemperatureMax: getDoubleFromJson('apparentTemperatureMax', json),
      apparentTemperatureMaxTime: json['apparentTemperatureMaxTime'],
    );
  }
}

double getDoubleFromJson(String key, Map<String, dynamic> json){
  return json.containsKey(key) ? json[key].toDouble() : null;
}
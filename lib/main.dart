import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
            children: [
              titleSection,
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(

          ),
          height: 50.0,
          child: Text(
              'This goes at the bottom',
          ),
        ),
      ),
    );
  }

  Widget footerSection = Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Icons provided by http://weathericons.io'
                )
              )
            ],
          ),
        )
      ],
    ),
  );

  Widget titleSection = Container(
    padding: const EdgeInsets.all(32),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '72°F',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 84,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 1.5,
                        color: Color.fromARGB(255, 0, 0, 0),
                      )
                    ],
                  ),
                ),
              ),
            ],
        ),
      ),
      Icon(
        Icons.wb_sunny,
        color: Colors.white,
        size: 72,
      )
    ]),
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
  String darkSkyApiKey = '579a77ae78f5ae084f9d856a3f4b474d';
  String time = '2019-04-08T22:35:00';
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
  final int precipProbability;
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
      precipProbability: json['precipProbability'],
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
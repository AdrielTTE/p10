import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'ForecastList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class Forecast {
  final String date;
  final String morning_forecast;
  final String afternoon_forecast;
  final String night_forecast;
  final String summary_forecast;
  final String summary_when;
  final int min_temp;
  final int max_temp;

  const Forecast({
    required this.date,
    required this.morning_forecast,
    required this.afternoon_forecast,
    required this.night_forecast,
    required this.summary_forecast,
    required this.summary_when,
    required this.min_temp,
    required this.max_temp
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
    'date': String date,

    'morning_forecast': String morning_forecast,
    'afternoon_forecast': String afternoon_forecast,
    'night_forecast': String night_forecast,
    'summary_forecast': String summary_forecast,
    'summary_when': String summary_when,
    'min_temp': int min_temp,
    'max_temp': int max_temp
    } =>
        Forecast(
            date: date,
            morning_forecast: morning_forecast,
            afternoon_forecast: afternoon_forecast,
            night_forecast: night_forecast,
            summary_forecast: summary_forecast,
            summary_when: summary_when,
            min_temp: min_temp,
            max_temp: max_temp
        ),
      _ => throw const FormatException('Failed to load forecast.'),
    };
  }
}


class _MyHomePageState extends State<MyHomePage> {

  final Map<String, String> states = {
  'St001': 'Perlis',
  'St002': 'Kedah',
  'St003': 'Pulau Pinang',
  'St004': 'Perak',
  'St005': 'Kelantan',
  'St006': 'Terengganu',
  'St007': 'Pahang',
  'St008': 'Selangor',
  'St009': 'WP Kuala Lumpur',
  'St010': 'WP Putrajaya',
  'St011': 'Negeri Sembilan',
  'St012': 'Melaka',
  'St013': 'Johor',
  'St501': 'Sarawak',
  'St502': 'Sabah',
  'St503': 'WP Labuan',
};

  String? _selectedState; // Store the selected state
  Future<List<Forecast>>? forecastData; // Store the Future

  Future<List<Forecast>> _fetchForecastData(String locationId) async {
    if (locationId.isEmpty) {
//Handle empty location ID
      return Future.value([]);
    }
    final url =
    Uri.parse('https://api.data.gov.my/weather/forecast?contains=$locationId@location__location_id&sort=date');
        try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
// If the server did return a 200 OK response, then parse the JSON.
        final jsonData = jsonDecode(response.body) as List;
        return jsonData.map((json) => Forecast.fromJson(json)).toList();
        } else {
// If the server did not return a 200 OK response, then throw an exception.
        throw Exception('Failed to load forecast : ${response.statusCode}');
        }
        } catch (e) {
      throw Exception('Error fetching forecast data : $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
        body: Center(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
//TODO: Insert a DropdownButton widget
    DropdownButton<String>(
    hint: Text('Select a State'),
    value: _selectedState, // The currently selected value
    iconEnabledColor: Colors.blueAccent,
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    elevation: 8,
    items: states.entries.map((entry) {
    return DropdownMenuItem<String>(
    value: entry.key, // Value when selected
    child: Text(entry.value), // Text displayed in the dropdown
    );
    }).toList(),
    onChanged: (String? newValue) {
    if (newValue != null) {
    setState(() {
    _selectedState = newValue; // State code
    forecastData = _fetchForecastData(newValue);
    });
    }
    },
    ),
//TODO: Insert an Expanded widget
    Expanded(
    child: FutureBuilder<List<Forecast>>(
    future: forecastData,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting &&
    forecastData != null) {
    return CircularProgressIndicator(
    strokeAlign: BorderSide.strokeAlignCenter,
    );
    } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    } else if (snapshot.hasData &&
    snapshot.data!.isNotEmpty) {
    return ForecastList(forecastData: snapshot.data!);
    } else {
    return Text('');
    }
    }),
    ),
//TODO: Insert a Text widget
    Text('Data Source: Malaysian Meteorological Department'),
    ],
    ),

    )
        )
    );
  }
}

final Map<String, String> weather_status = {
  'Berjerebu': 'haze.png',
  'Tiada': 'sunny.png',
  'Hujan': 'rainy.png',
  'Ribut': 'thunderstorm.png',

};



class ForecastList extends StatelessWidget {

  const ForecastList({super.key, required this.forecastData});
  final List<Forecast> forecastData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: forecastData.length,
        itemBuilder: (context, index){

      return ListView.builder(
          itemCount: forecastData.length,
          itemBuilder: (context, index) {
            final forecast = forecastData[index];
            return Card(
              color: Colors.white,
              child: ListTile(
                  title: Text('${forecast.min_temp}°C ${forecast.max_temp}°C',),
                  leading:
                  Text('${DateFormat('yyyy-MM-dd').parse(forecast.date).day} ${DateFormat('yyyy-MM-dd').parse(forecast.date).month}',
                    style: TextStyle(color: Colors.grey, fontSize: 20,)),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Morning'),

                      weather_status[forecast.morning_forecast] != null

                          ? Image.asset(
                        'assets/images/${weather_status[forecast.morning_forecast].toString()}',
                        width: 48, height: 48,)
                          : Image.asset('assets/images/unknown.png', width: 48, height: 48,),
                    ],
                  ),
                  Expanded(child: SizedBox(),),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Afternoon'),

                      weather_status[forecast.afternoon_forecast] != null

                          ? Image.asset(
                        'assets/images/${weather_status[forecast.afternoon_forecast].toString()}',
                        width: 48, height: 48,)
                          : Image.asset('assets/images/unknown.png', width: 48, height: 48,),
                    ],
                  ),
                  Expanded(child: SizedBox(),),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Night'),

                      weather_status[forecast.night_forecast] != null

                          ? Image.asset(
                        'assets/images/${weather_status[forecast.night_forecast].toString()}',
                        width: 48, height: 48,)
                          : Image.asset('assets/images/unknown.png', width: 48, height: 48,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            );
          });
    });
  }

  }





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/provider/weather_provider.dart';
import 'package:weather/setting_page.dart';
import 'package:weather/weather_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>WeatherProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark
        ),
        home: WeatherHome(),
        routes: {
          WeatherHome.routeName:(context)=>WeatherHome(),
          SettingPage.routeName:(context)=>SettingPage()
        },
      ),
    );
  }
}

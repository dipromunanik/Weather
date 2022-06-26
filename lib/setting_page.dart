import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/provider/weather_provider.dart';

class SettingPage extends StatefulWidget {
  static const String routeName ='setting_page';
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late WeatherProvider _provider;

  @override
  void didChangeDependencies() {
    _provider = Provider.of<WeatherProvider>(context);
    _provider.getStatus();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Setting',style: TextStyle(color: Colors.white,fontSize: 20)),
      ),
      body: ListView(
        padding:  const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
              value: _provider.status,
              onChanged: (value){
                _provider.setStatus(value);
              },
            title: Text('Show temperature in Fahrenheit'),
            subtitle:const Text('Default in Celsius'),
          )
        ],
      ),
    );
  }
}

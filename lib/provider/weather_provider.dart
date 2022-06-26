
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather/models/current_models.dart';
import 'package:weather/models/forecast_models.dart';
import 'package:weather/utils/constant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as Http;
import 'package:weather/utils/helper_function.dart';

class WeatherProvider with ChangeNotifier{
  double latitude =0.0;
  double longitude =0.0;
  CurrentModels? currentModels;
  ForecastModels? forecastModels;
  bool status =false;
  String tempUnit ='metric';
  
  void setStatus(bool status) async{
    this.status =status;
    await setTempStatus(status);
    tempUnit =status ? 'imperial':'metric';
    getData();
    notifyListeners();
  }
  void getStatus() async{
    status = await getTempStatus();
    tempUnit =status ? 'imperial':'metric';
    getData();
  }

  void setNewPosition(double lat,double long){
    latitude =lat;
    longitude=long;
  }
  void getData(){
    _getCurrentData();
    _getForecastData();
  }
  Future<void> _getCurrentData() async {
    final url ='https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$tempUnit&appid=$weatherApiKey';

    try{
      final response =await Http.get(Uri.parse(url));

      if(response.statusCode==200){
        final map =json.decode(response.body);
        currentModels =CurrentModels.fromJson(map);
        notifyListeners();
      }

    }catch(err){
      throw err;
    }

  }
  Future<void> _getForecastData() async {
    final url ='https://api.openweathermap.org/data/2.5/forecast?lat=23.7112566&lon=90.355159&units=$tempUnit&appid=a16941a104aa127db2c7c036b7eb825b';

    try{
      final response =await Http.get(Uri.parse(url));

      if(response.statusCode==200){
        final map =json.decode(response.body);
        forecastModels =ForecastModels.fromJson(map);
        notifyListeners();
      }

    }catch(err){
      throw err;
    }
  }
}


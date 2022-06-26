import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/provider/weather_provider.dart';
import 'package:weather/setting_page.dart';
import 'package:weather/utils/constant.dart';
import 'package:weather/utils/helper_function.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:intl/intl.dart';

class WeatherHome extends StatefulWidget {
  static const String routeName = 'weather_home';

  const WeatherHome({Key? key}) : super(key: key);

  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  late WeatherProvider _provider;
  bool _isInit = true;

  void didChangeDependencies() {
    if (_isInit) {
      _provider = Provider.of<WeatherProvider>(context);
      _init();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _init() {
    determinePosition().then((position) {
      print('${position.latitude} ${position.longitude}');
      _provider.setNewPosition(position.latitude, position.longitude);
      _provider.getStatus();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'weather',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _init();
              },
              icon: const Icon(Icons.my_location)),
          IconButton(
              onPressed: () async {
               final city =await showSearch(context: context, delegate: _CitySearchDelegate());
               if(city ==null || city.isEmpty){
                 return;
               }
               _convertCityToCoordinator(city);
              },
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, SettingPage.routeName);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Stack(children: [
        Image.asset(
          'images/background.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Center(
            widthFactor: 50,
            heightFactor: 100,
            child: _provider.currentModels != null &&
                    _provider.forecastModels != null
                ? ListView(children: [
                    Padding(
                      padding:const EdgeInsets.only(left: 20,right: 10,top: 30),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_provider.currentModels!.name}',
                                    style:const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    getFormattedDate(
                                        _provider.currentModels!.dt!, 'dd MMM yyyy'),
                                    style:const TextStyle(
                                        fontSize: 20),
                                  ),
                                  const SizedBox(height:40),
                                Container(
                                  height: 100,
                                  width: 180,
                                  margin:const EdgeInsets.only(right: 10, bottom: 40),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Feels like: ${_provider.currentModels!.main!.feelsLike!.round()}\u00B0',
                                              style:const TextStyle(
                                                  fontSize: 18)),
                                          Text(
                                            'Pressure: ${_provider.currentModels!.main!.pressure} mm',
                                            style:const TextStyle(
                                                fontSize: 18),
                                          ),
                                          Text(
                                            'Humidity: ${_provider.currentModels!.main!.humidity}%',
                                            style:const TextStyle(
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )

                                ],
                              ),
                              Column(
                                children: [
                                  TweenAnimationBuilder(
                                    curve: Curves.easeInOut,
                                    duration: const Duration(seconds: 2),
                                    tween: IntTween(
                                        begin: 0,
                                        end:
                                        _provider.currentModels!.main!.temp!.round()),
                                    builder: (context, value, _) => Text(
                                      '$value\u00B0',
                                      style:const TextStyle(
                                          fontSize: 70,fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  Image.network(
                                      '$prefix_icon${_provider.currentModels!.weather![0].icon}$sufix_icon',
                                      width: 90,
                                      height: 90),
                                  Text(
                                    '${_provider.currentModels!.weather![0].description}',
                                    style:const TextStyle(
                                        fontSize: 18),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            getFormattedDate(
                                _provider.currentModels!.dt!, 'hh:mm aa'),
                            style:const TextStyle(
                                fontSize: 35),
                          ),
                          Text(
                            'MET ${_provider.currentModels!.name}',
                            style:const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          RotationTransition(
                              turns: _animation,
                              child: Image.asset('images/turbine.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover)),
                          Text(
                              'Wind Speed: ${_provider.currentModels!.wind!.speed}',
                              style:const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                   const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _provider.forecastModels!.list!.length,
                        itemBuilder: (context, i) {
                          final item = _provider.forecastModels!.list![i];
                          return Container(
                            width: 150,
                            margin:const EdgeInsets.only(right: 10, bottom: 40),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.4),
                            ),
                            child: Padding(
                              padding:const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(getFormattedDate(
                                        item.dt!, 'EEE HH:mm aa'),style:const TextStyle(
                                      fontSize: 14
                                    ),),
                                    Image.network(
                                        '$prefix_icon${item.weather![0].icon}$sufix_icon',
                                        width: 70,
                                        height: 70,),
                                    Text(
                                        '${item.main!.tempMax!.round()}/${item.main!.tempMin!.round()}\u00B0',
                                    style:const TextStyle(fontSize: 16),),
                                    Text('${item.weather![0].description}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ])
                : const Text('Please wait....'))
      ]),
    );
  }

  void _convertCityToCoordinator(String city) async{
   try{
     final locationList =await Geo.locationFromAddress(city);
     if(locationList.isNotEmpty){
       final location =locationList.first;
       _provider.setNewPosition(location.latitude, location.longitude);
       _provider.getData();
     }
   }catch(error){
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
   }
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(onPressed: () {
      
    }, icon: const Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: () {
      Navigator.pop(context);
    }, icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.search),
      title: Text(query),
      onTap: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty ? cities : cities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();

    return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                query = filteredList[index];
                close(context, query);
              },
              title: Text(filteredList[index]),
            ));
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_movil_sirap/gps/gps.dart';
import 'package:geolocator/geolocator.dart';
import 'gps/gps.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP Sirap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SIRAP APP'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Position _positionAc;
  double _altitud = 0;
  double _longitud = 0;
  double _latitud = 0;
  double px = 0;
  double py = 0;

  Future<void> _updateGeo() async {
    _positionAc = await _determinePosition();
    setState(() {
      _altitud = _positionAc.altitude;
      _latitud = _positionAc.latitude;
      _longitud = _positionAc.longitude;
      px = ((_longitud + 75.49389190549414) * 0.843073365285164) -
          ((_latitud - 5.0559390694892565) * 0.53779856893334);
      py = ((_longitud + 75.49389190549414) * 0.53779856893334) +
          ((_latitud - 5.0559390694892565) * 0.843073365285164);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 15,
        constrained: false,
        child: Stack(
          children: <Widget>[
            Image(
              image: AssetImage('assets/piso2.png'),
              width: MediaQuery.of(context).size.width,
            ),
            py <= 0 &&
                    py >= -0.000659064055465 &&
                    px >= 0 &&
                    px <= 0.000138612591629
                ? Positioned(
                    top: (py / -0.000659064055465 - 0.005) *
                        MediaQuery.of(context).size.width *
                        4.5734870317002881,
                    left: ((px / 0.000138612591629) - 0.05) *
                        MediaQuery.of(context).size.width,
                    child: Image(
                      image: AssetImage('assets/xokas.png'),
                      width: MediaQuery.of(context).size.width * 0.10,
                    ))
                : Positioned(
                    top: 50,
                    left: 50,
                    child: Text(
                      'longitud:${_longitud + 75.49389190549414} latidud:${_latitud - 5.0559390694892565} x:${LocationLogic.px} y:${LocationLogic.py}',
                      style: TextStyle(color: Color.fromARGB(255, 3, 0, 0)),
                    ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateGeo,
        tooltip: 'Actualizar',
        child: const Icon(Icons.add),
      ),
    );
  }
}

//--DEBERIA DEBERIA PODERSE USAR DESDE EL gps.dart, pero aun no descubro como usar cosas de otros archivos
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
  LocationPermission permission2 = await Geolocator.requestPermission();
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    await Geolocator.openAppSettings();
    await Geolocator.openLocationSettings();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);
StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
  print(position == null
      ? 'Unknown'
      : '${position.latitude.toString()}, ${position.longitude.toString()}');
});

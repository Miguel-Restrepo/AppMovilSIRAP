import 'dart:async';

import 'package:geolocator/geolocator.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.openAppSettings();
    await Geolocator.openLocationSettings();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

//PARTE PARA QUE SEA EN TIEMPO REAL--> NO PROBADO
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

class LocationLogic {
  static late Position _positionAc;
  static double _altitud = 0;
  static double _longitud = 0;
  static double _latitud = 0;
  static double px = 0;
  static double py = 0;

  static void startListeningToLocationUpdates() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        _altitud = position.altitude;
        _latitud = position.latitude;
        _longitud = position.longitude;
        px = ((_longitud + 75.49389190549414) * 0.843073365285164) -
            ((_latitud - 5.0559390694892565) * 0.53779856893334);
        py = ((_longitud + 75.49389190549414) * 0.53779856893334) +
            ((_latitud - 5.0559390694892565) * 0.843073365285164);
      }
    });
  }
}

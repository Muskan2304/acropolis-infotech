import 'package:applore/services/geolocator_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();

  //variables
   Position? currentLocation;
  ApplicationBloc(){
    setCurrentLocation();
  }
  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    notifyListeners();
  }
  }
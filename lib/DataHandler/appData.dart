import 'package:flutter/material.dart';
import 'package:rider_app/Models/Address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation;
  Address currentAddress;
  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateCurrentLocationAddress(Address pickUpAddress) {
    currentAddress = pickUpAddress;
    notifyListeners();
  }
}

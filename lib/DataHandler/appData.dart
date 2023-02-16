import 'package:flutter/material.dart';
import 'package:rider_app/Models/Address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation;
  Address currentAddress;
  Address dropOffLocation;
  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateCurrentLocationAddress(Address currentAddress) {
    currentAddress = currentAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}

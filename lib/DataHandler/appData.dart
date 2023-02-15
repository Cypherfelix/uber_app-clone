import 'package:flutter/material.dart';
import 'package:rider_app/Models/Address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation;
  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }
}
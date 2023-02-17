import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/Address.dart';
import 'package:rider_app/Models/DirectionDetails.dart';
import 'package:rider_app/Models/Users.dart';
import 'package:rider_app/configMap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context, update) async {
    String placeAddress = "";
    String st1, st2, st3, st4, st5;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url, "json");

    if (response != "Failed") {
      // placeAddress = response["results"][0]["formatted_address"];

      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][2]["long_name"];
      st3 = response["results"][0]["address_components"][4]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3;

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      update(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirection(
      Address initialPosition, Address finalPosition) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(url, "json");

    if (res.toString().toLowerCase() == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];
    print(directionDetails == null);
    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
//in terms USD
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0;
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.27;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    totalFareAmount = totalFareAmount * 150;
//Local Currency
//1$ = 160 RS
//double total LocalAmount = total FareAmount * 160;
    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("users").child(userId);

    print("Hello There!");
    await reference.once().then((value) {
      currentUser = Users.fromSnapshot(value.snapshot);
      print(currentUser.name);
    }, onError: (e) {
      print("Error");
    });
  }
}

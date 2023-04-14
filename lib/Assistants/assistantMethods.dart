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
    double timeTraveledFare = (directionDetails.durationValue / 60);
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.27;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    totalFareAmount = totalFareAmount * 150;
    return totalFareAmount.truncate();
  }

  static int getFareForCar(DirectionDetails directionDetails, int baseFare) {
    // Define the base fare, cost per km, and cost per minute.
    double minimumFare = 120.50;
    double costPerKm = 16.50;
    double costPerMinute = 3.50;
    int distanceKm = directionDetails.durationValue ~/ 60;
    int timeMinutes = directionDetails.distanceValue ~/ 1000;

    // Calculate the distance and time components of the fare.
    double distanceFare = distanceKm * costPerKm;
    double timeFare = timeMinutes * costPerMinute;

    // Combine the distance and time components to get the total fare.
    double totalFare = baseFare + distanceFare + timeFare;

    // Return the total fare, with a minimum of the minimum fare.
    return (totalFare > minimumFare ? totalFare : minimumFare).toInt();
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

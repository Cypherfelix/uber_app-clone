import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/DividerWidget.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/Address.dart';
import 'package:rider_app/Models/PlacesPrediction.dart';
import 'package:rider_app/Models/placesPredictions.dart';
import 'package:rider_app/configMap.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController dropoffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickupTextEditingController.text = placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 30.0,
                left: 25.0,
                right: 25.0,
                bottom: 20.0,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "BrandBold",
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/pickicon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickupTextEditingController,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/desticon.png",
                        height: 16.0,
                        width: 16.0,
                      ),
                      SizedBox(
                        width: 18.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (value) {
                                findPlaces(value);
                              },
                              controller: dropoffTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Where to ?",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePrediction: placePredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, index) =>
                        DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlaces(String placename) async {
    if (placename.length > 1) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placename&components=country:ke&key=$mapKey";

      var res = await RequestAssistant.getRequest(url, "json");

      if (res.toString().toLowerCase() == "Failed".toLowerCase()) {
        return;
      }

      print(res["status"]);
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }

      // Map<String, dynamic> map = jsonDecode(res.toString());
      // var myRootNode = Root.fromJson(map);

      // print(myRootNode.predictions.length);
    } else {
      setState(() {
        placePredictionList = [];
      });
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePrediction;

  const PredictionTile({Key key, this.placePrediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDetails(placePrediction.place_id, context);
      },
      style: ButtonStyle(
        padding: MaterialStatePropertyAll(EdgeInsets.all(0.0)),
      ),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 8.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        placePrediction.main_text,
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        placePrediction.secondary_text,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting drop off. Please wait...",
      ),
    );

    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var res = await RequestAssistant.getRequest(url, "json");

    if (res == "Failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);

      print(address.placeName);

      Navigator.pop(context);
    }
  }
}

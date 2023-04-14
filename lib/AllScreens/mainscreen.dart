import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/loginscreen.dart';
import 'package:rider_app/AllScreens/registrationScreen.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/DividerWidget.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/DirectionDetails.dart';
import 'package:intl/intl.dart';
import 'package:rider_app/configMap.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "main";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController newGoogleMapController;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSets = new Set<Polyline>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DirectionDetails tripDirectionDetails;

  Position currentPosition;

  bool drawerOpen = true;

  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 0;

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  double rideDetailsContainer = 0;
  double searchContainerHeight = 310;
  double requestRideContainer = 0;

  DatabaseReference rideRequestReference;

  var colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  var data = [
    {
      "type": "Saloon",
      "icon": "images/saloon-nobg.png",
      "state": "Available",
      "size": 4,
      "currentPrice": 70,
      "NewPrice": 65,
    },
    {
      "type": "Mini Bus",
      "icon": "images/bus-nobg.png",
      "state": "Available",
      "size": 14,
      "currentPrice": 50,
      "NewPrice": 30,
    },
    {
      "type": "Bus",
      "icon": "images/bus-nobg.png",
      "state": "Available",
      "size": 23,
      "currentPrice": 55,
      "NewPrice": 60,
    },
    {
      "type": "Rider",
      "icon": "images/ride-nobg.png",
      "state": "Available",
      "size": 1,
      "currentPrice": 100,
      "NewPrice": 110,
    }
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Signatra',
  );

  int selectedCar = -1;

  resetApp() {
    setState(() {
      searchContainerHeight = 310;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 310.0;
      requestRideContainer = 0;
      drawerOpen = true;
      markers.clear();
      circles.clear();
      polyLineSets.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainer = 320;
      bottomPaddingOfMap = 340.0;
      drawerOpen = false;
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainer = 250;
      rideDetailsContainer = 0;
      bottomPaddingOfMap = 270.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  void locatePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = new LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(
        position,
        context,
        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress);

    address = await AssistantMethods.searchCoordinateAddress(
        position,
        context,
        Provider.of<AppData>(context, listen: false)
            .updateCurrentLocationAddress);

    print(address);
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void saveRideRequest() {
    rideRequestReference =
        FirebaseDatabase.instance.ref().child("Ride Request").push();

    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUp = {
      "latitude": initialPos.latitude,
      "longitude": initialPos.longitude
    };

    Map dropOff = {
      "latitude": finalPos.latitude,
      "longitude": finalPos.longitude
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUp,
      "dropoff": dropOff,
      "created_at": DateTime.now().toString(),
      "rider_name": currentUser.name,
      "rider_phone": currentUser.phone,
      "pickup_address": initialPos.placeName,
      "dropoff_address": finalPos.placeName,
    };

    rideRequestReference.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestReference.remove();
  }

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "NoStress Safaris",
          style: TextStyle(
            fontFamily: "Brand-Regular",
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(children: [
                    Image.asset(
                      "images/user_icon.png",
                      height: 65.0,
                      width: 65.0,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Profile Name",
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: "Brand Bold"),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text("Visit Profile"),
                      ],
                    )
                  ]),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return ProgressDialog(
                        message: "Signing Out, Please wait...",
                      );
                    },
                  );
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                    displayToastMessage('Sign Out successful.', context);
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    displayToastMessage('Something went wrong.', context);
                  }
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(
                    "Log Out",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            markers: markers,
            circles: circles,
            polylines: polyLineSets,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 320.0;
              });
              locatePosition();
            },
          ),
          // Positioned(
          //   top: 30.0,
          //   left: 22.0,
          //   child: GestureDetector(
          //     onTap: () {
          //       if (drawerOpen) {
          //         scaffoldKey.currentState.openDrawer();
          //       } else {
          //         resetApp();
          //       }
          //     },
          //     child: Container(
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(22.0),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black,
          //               blurRadius: 6.0,
          //               spreadRadius: 0.5,
          //               offset: Offset(0.7, 0.7),
          //             )
          //           ]),
          //       child: CircleAvatar(
          //         backgroundColor: Colors.white,
          //         child: Icon(
          //           drawerOpen ? Icons.menu : Icons.close,
          //           color: Colors.black,
          //         ),
          //         radius: 20.0,
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 16.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 6.0,
                        ),
                        Text(
                          "Hi there",
                          style: TextStyle(fontSize: 12.0),
                        ),
                        Text(
                          "Where to",
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: "Brand Bold"),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchScreen(),
                              ),
                            );

                            if (res == "obtainDirections") {
                              displayRideDetailsContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 6.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7))
                                ]),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text("Search Drop Off")
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.home, color: Colors.grey),
                            SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AppData>(context)
                                              .pickUpLocation !=
                                          null
                                      ? Provider.of<AppData>(context)
                                          .pickUpLocation
                                          .placeName
                                      : "Add Home",
                                  overflow: TextOverflow.fade,
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "Your living home address",
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 12.0),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        DividerWidget(),
                        SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.work, color: Colors.grey),
                            SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Add Work"),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Text(
                                  "Your office address",
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 12.0),
                                )
                              ],
                            )
                          ],
                        ),
                      ]),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainer,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Image.asset(
                                      "images/pickicon.png",
                                      height: 40.0,
                                      width: 50.0,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tripDirectionDetails != null
                                              ? "Arrive in " +
                                                  tripDirectionDetails
                                                      .durationText
                                              : "",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.blueAccent,
                                              fontFamily: "Brand Bold"),
                                        ),
                                        Text(
                                          (tripDirectionDetails != null)
                                              ? tripDirectionDetails
                                                  .distanceText
                                              : "",
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 60,
                              ),
                              Padding(
                                child: GestureDetector(
                                  onTap: () {
                                    resetApp();
                                  },
                                  child: Text(
                                    "X",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.only(bottom: 3),
                              )
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Container(
                            height: 190,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 10,
                                left: 10,
                                right: 10,
                              ),
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedCar = index;
                                      });
                                    },
                                    child: UberType(
                                      index: index,
                                      car: data[index],
                                      directionDetails: tripDirectionDetails,
                                      selected: selectedCar,
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider();
                                },
                                itemCount: 4,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              displayRequestRideContainer();
                            },
                            style: ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll(
                                  Theme.of(context).colorScheme.primary),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Request",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    FontAwesomeIcons.taxi,
                                    color: Colors.white,
                                    size: 26.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: requestRideContainer,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                // height: 250.0,
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Requesting a Ride',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                            ColorizeAnimatedText(
                              'Please wait...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                            ColorizeAnimatedText(
                              'Finding a driver...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                      SizedBox(
                        height: 22.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.0),
                            border: Border.all(
                              width: 2.0,
                              color: Colors.grey[300],
                            ),
                          ),
                          child: Icon(Icons.close, size: 26.0),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Cancel Ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));
    var details =
        await AssistantMethods.obtainPlaceDirection(initialPos, finalPos);
    Navigator.pop(context);

    setState(() {
      tripDirectionDetails = details;
    });

    if (details != null) {
      PolylinePoints polyLinePoints = PolylinePoints();
      List<PointLatLng> decodedPolyLinePointsResult =
          polyLinePoints.decodePolyline(details.encodedPoints);

      pLineCoordinates.clear();
      if (decodedPolyLinePointsResult.isNotEmpty) {
        decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
          pLineCoordinates
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

      polyLineSets.clear();
      setState(() {
        Polyline polyLine = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        );

        polyLineSets.add(polyLine);
      });

      LatLngBounds latLngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds = LatLngBounds(
          southwest: dropOffLatLng,
          northeast: pickUpLatLng,
        );
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
        );
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
        );
      } else {
        latLngBounds = LatLngBounds(
          southwest: pickUpLatLng,
          northeast: dropOffLatLng,
        );
      }

      newGoogleMapController
          .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      Marker pickUpMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: initialPos.placeName,
          snippet: "my location",
        ),
        position: pickUpLatLng,
        markerId: MarkerId("pickUpId"),
      );
      Marker dropOffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: finalPos.placeName,
          snippet: "Drop off location",
        ),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"),
      );

      setState(() {
        markers.addAll([pickUpMarker, dropOffMarker]);
      });

      Circle pickUpCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId("pickUpID"),
      );

      Circle dropOffCircle = Circle(
        fillColor: Colors.purple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: CircleId("dropOffID"),
      );

      setState(() {
        circles.add(pickUpCircle);
        circles.add(dropOffCircle);
      });
    }
  }
}

class UberType extends StatelessWidget {
  final int index;
  var car;
  DirectionDetails directionDetails;
  int selected;
  UberType({
    Key key,
    this.index,
    this.car,
    this.directionDetails,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected == index ? Colors.black12 : Colors.white,
      child: Row(
        children: [
          Image(
            image: AssetImage(car['icon']),
            height: 80.0,
            width: 80.0,
          ),
          SizedBox(
            width: 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                alignment: Alignment.centerLeft,
                child: Text(
                  car['type'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: 3,
              ),
              Row(
                children: [
                  Text(car['state']),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.person_rounded,
                    size: 20,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(car['size'].toString()),
                ],
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            children: [
              Text(
                "Ksh " +
                    AssistantMethods.getFareForCar(
                            directionDetails, car['NewPrice'])
                        .toString(),
                style: TextStyle(fontSize: 20, fontFamily: "Helvetica"),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Ksh " +
                    AssistantMethods.getFareForCar(
                            directionDetails, car['currentPrice'])
                        .toString(),
                style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Halvetica',
                    decoration: TextDecoration.lineThrough),
              )
            ],
          )
        ],
      ),
    );
  }
}

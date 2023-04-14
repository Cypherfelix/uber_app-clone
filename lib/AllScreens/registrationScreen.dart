import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/loginscreen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/main.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController phoneTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  bool waiting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 25.0,
              ),
              Image(
                image: AssetImage("images/logo-nobg.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.bottomCenter,
              ),
              SizedBox(height: 1.0),
              Text(
                "Register User",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                      controller: nameTextEditingController,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                      controller: emailTextEditingController,
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                      controller: phoneTextEditingController,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(fontSize: 14.0),
                      controller: passwordTextEditingController,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      onPressed: waiting
                          ? null
                          : () {
                              if (nameTextEditingController.text.length < 3) {
                                displayToastMessage(
                                    "Name must be at least 3 Characters.",
                                    context);
                              } else if (!emailTextEditingController.text
                                  .contains("@")) {
                                displayToastMessage(
                                    "Email address is not valid.", context);
                              } else if (phoneTextEditingController
                                  .text.isEmpty) {
                                displayToastMessage(
                                    "Phone Number is mandatory.", context);
                              } else if (passwordTextEditingController
                                      .text.length <
                                  6) {
                                displayToastMessage(
                                    "Password must be at least 6 Characters.",
                                    context);
                              } else {
                                registerNewUser(context);
                              }
                            },
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: waiting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // ignore: prefer_const_literals_to_create_immutables
                                  children: [
                                    const Text(
                                      'Loading...',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ],
                                )
                              : Text(
                                  "Create an Account",
                                  style: TextStyle(
                                      fontSize: 18.0, fontFamily: "Brand Bold"),
                                ),
                        ),
                      ),
                      style: ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(
                            new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(24.0))),
                        backgroundColor: MaterialStatePropertyAll(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: Text("Already have an account? Login here."),
              )
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(
          message: "Registering, Please wait...",
        );
      },
    );
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((error) {
      Navigator.pop(context);
      displayToastMessage("Error: " + error.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      //save user info to database
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage("Account created successfully.", context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage("User not created", context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}

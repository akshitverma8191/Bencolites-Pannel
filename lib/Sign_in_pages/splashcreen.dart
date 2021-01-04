import 'package:Bencolites_Pannel/Home_activities/home.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/login.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class splash_screen extends StatefulWidget {
  bool login;

  splash_screen({this.login}) {
    print('LOGIN STATUS HERE ----------------------------------');
    print(this.login);
  }
  @override
  _splash_screenState createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: widget.login == true ? home() : login_ui(),
      title: Text('Welcome to Bencolites Pannel'),
    );
  }
}

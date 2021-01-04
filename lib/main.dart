import 'package:Bencolites_Pannel/Sign_in_pages/splashcreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class login_credentials {
  void logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('phone', null);
    pref.setBool('login', null);
  }

  void login({String phone, String password}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('phone', phone);
    pref.setString('password', password);
    pref.setBool('login', true);
  }

  login_status() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var x = await pref.get('login');
    return x;
  }

  Future getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var x = await pref.getString('phone');
    return x.toString();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // var _auth = FirebaseAuth.instance;
  // var user = _auth.currentUser;
  var login = login_credentials();
  bool x = await login.login_status();

  runApp(Myapp(
    login: x,
  ));
}

class Myapp extends StatefulWidget {
  var user;
  bool login;
  Myapp({this.user, this.login}) {}
  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<Myapp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: splash_screen(
        login: widget.login,
      ),
    );
  }
}
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// import 'login.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Firebase.initializeApp();
//   runApp(MaterialApp(
//     home: MyApp(),
//     debugShowCheckedModeBanner: false,
//   ));
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return LoginScreen();
//   }
// }

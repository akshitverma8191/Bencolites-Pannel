import 'package:Bencolites_Pannel/Home_activities/home.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/otp_page.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/register.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:Bencolites_Pannel/main.dart';

class login_ui extends StatefulWidget {
  @override
  _login_uiState createState() => _login_uiState();
}

class _login_uiState extends State<login_ui> {
  TextEditingController _controller;
  String password;
  bool error_text = false;

  login() async {
    Loader.show(context,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal[300]),
        ));
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var result = await firestore.collection('/users').get();
    for (var data in result.docs) {
      if (data.id == _controller.text.trim()) {
        if (data.data()['password'] == password) {
          var local = login_credentials();
          await local.login(phone: _controller.text.trim(), password: password);

          Loader.hide();
          Navigator.pop(context);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => home()));
        }
      }
    }
    Loader.hide();
    setState(() {
      error_text = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController(text: '+91');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.1,
      color: Colors.teal[300],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .8,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(160),
                    bottomRight: Radius.circular(160)),
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10,
                        left: MediaQuery.of(context).size.width * .445),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .05),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .15,
                        left: MediaQuery.of(context).size.width * .1,
                        right: MediaQuery.of(context).size.width * .1,
                        bottom: MediaQuery.of(context).size.height * .10),
                    child: Card(
                      elevation: 4.0,
                      shadowColor: Colors.grey,
                      child: Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * 7,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .1,
                                left: MediaQuery.of(context).size.width * .1,
                                right: MediaQuery.of(context).size.width * .1,
                              ),
                              // ######################################## Textfield one is here to get the phone number
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: 'No.- +91828....',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.teal[300]),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * .05,
                                  left: MediaQuery.of(context).size.width * .1,
                                  right: MediaQuery.of(context).size.width * .1,
                                ),
                                //################################ Textfield 2 to get the password
                                child: TextField(
                                  obscureText: true,
                                  onChanged: (e) {
                                    password = e;
                                    setState(() {
                                      error_text = false;
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: error_text
                                      ? InputDecoration(
                                          hintText: 'Enter Password',
                                          errorText: 'Invalid Password',
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal[300]),
                                          ),
                                        )
                                      : InputDecoration(
                                          hintText: 'Enter Password',
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.teal[300]),
                                          ),
                                        ),
                                )),
                            Padding(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .05,
                                left: MediaQuery.of(context).size.width * .1,
                                right: MediaQuery.of(context).size.width * .1,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.login),
                                onPressed: () async {
                                  await login();
                                  // Login press button code here
                                  // Navigator.pop(context);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (BuildContext context) =>
                                  //             home()));
                                },
                                color: Colors.teal[300],
                                iconSize:
                                    MediaQuery.of(context).size.width * .1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .10,
                        left: MediaQuery.of(context).size.width * .40),
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width),
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * .09,
                        width: MediaQuery.of(context).size.width * .17,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/login.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * .05,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .1,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      //  Forgot Password code here
                    },
                    child: Text(
                      'Forgot Passowrd?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * .04),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // New user page navigation code here
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  mobile_verification()));
                    },
                    child: Text(
                      'Register New User !',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * .04),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class mobile_verification extends StatefulWidget {
  @override
  _mobile_verificationState createState() => _mobile_verificationState();
}

class _mobile_verificationState extends State<mobile_verification> {
  TextEditingController _controller;
  TextEditingController _controller1;
  String mobile_number;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _controller = TextEditingController(text: '+91');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
              child: CircleAvatar(
                backgroundColor: Colors.teal[300],
                radius: MediaQuery.of(context).size.height * .1,
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * .1,
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .3,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .12),
                      child: TextField(
                        controller: _controller,

                        //onchange country code saves here
                        decoration: InputDecoration(
                          hintText: '+91',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal[300]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .6,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .10),
                      child: TextField(
                        onChanged: (no) {
                          mobile_number = _controller.text.trim() + no;
                        },
                        //ONchange number save here
                        decoration: InputDecoration(
                          hintText: 'Enter Mobile Number',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal[300]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .1,
                left: MediaQuery.of(context).size.width * .09,
                right: MediaQuery.of(context).size.width * .09,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => mobile_otp(
                            mobile_number: mobile_number,
                          )));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (BuildContext context) => mobile_otp(
                  //               mobile_number: mobile_number,
                  //             )));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * .1,
                  child: Center(
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

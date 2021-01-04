import 'package:Bencolites_Pannel/Home_activities/home.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/login.dart';
import 'package:flutter/material.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:Bencolites_Pannel/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class register extends StatefulWidget {
  String mobie_number;
  register({this.mobie_number}) {}
  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  String name;
  String batch;
  String rollno;
  String password;
  String confirm_password = '';
  bool error_password = false;
  bool error_password1 = false;

  register_user() async {
    Loader.show(context,
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal[300]),
        ));
    String name_lower = name.toLowerCase();
    String name_upper = name.toUpperCase();

    List<String> case_search_lower = List();

    String templ = "";
    for (int i = 0; i < name_lower.length; i++) {
      templ = templ + name_lower[i];
      case_search_lower.add(templ);
    }
    var firestore = FirebaseFirestore.instance;
    await firestore.collection('/users').doc(widget.mobie_number).set({
      'name': name,
      'batch': batch,
      'rollno': rollno,
      'password': password,
      'adminstatus': false,
      'imageurl': '',
      'about': '',
      'casesearch_lower': case_search_lower,
    });
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal[300],
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 0,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Arc(
                    height: MediaQuery.of(context).size.height * .08,
                    //arcType: ArcType.CONVEX,
                    child: Container(
                      height: MediaQuery.of(context).size.height * .08,
                      width: MediaQuery.of(context).size.width * .5,
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * .07),
                        ),
                      ),
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .18,
                  left: MediaQuery.of(context).size.width * .075),
              child: Card(
                elevation: 6.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                shadowColor: Colors.grey[700],
                child: Container(
                  height: MediaQuery.of(context).size.height * .6,
                  width: MediaQuery.of(context).size.width * .8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  // All input fields on car will be coded here
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .065,
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1),
                        child: TextField(
                          textAlign: TextAlign.center,
                          onChanged: (e) {
                            name = e;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter Full Name',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal[300]),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * .1,
                              top: MediaQuery.of(context).size.width * .07,
                            ),
                            width: MediaQuery.of(context).size.width * .2,
                            child: TextField(
                              onChanged: (e) {
                                batch = e;
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Batch',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.teal[300]),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * .1,
                                top: MediaQuery.of(context).size.width * .07,
                                right: MediaQuery.of(context).size.width * .1),
                            width: MediaQuery.of(context).size.width * .3,
                            child: TextField(
                              onChanged: (e) {
                                rollno = e;
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: 'Roll No.',
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.teal[300]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * .07,
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1),
                        child: TextField(
                          obscureText: true,
                          textAlign: TextAlign.center,
                          onSubmitted: (e) {
                            if (e.length < 6) {
                              error_password1 = true;
                            }
                          },
                          onChanged: (e) {
                            error_password1 = false;
                            password = e;
                          },
                          decoration: error_password1
                              ? InputDecoration(
                                  hintText: 'Enter Password',
                                  errorText:
                                      'Password must be atleast 6 characters',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.teal[300]),
                                  ),
                                )
                              : InputDecoration(
                                  hintText: 'Enter Password',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.teal[300]),
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * .07,
                            left: MediaQuery.of(context).size.width * .1,
                            right: MediaQuery.of(context).size.width * .1),
                        child: TextField(
                          obscureText: true,
                          textAlign: TextAlign.center,
                          onChanged: (e) {
                            confirm_password = e;

                            error_password = false;
                          },
                          onSubmitted: (e) {
                            if (confirm_password != password) {
                              error_password = true;
                            }
                          },
                          decoration: error_password
                              ? InputDecoration(
                                  errorText: 'Password did not Match',
                                  hintText: 'Confirm Password',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.teal[300]),
                                  ),
                                )
                              : InputDecoration(
                                  hintText: 'Confirm Password',
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.teal[300]),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .145,
                  left: MediaQuery.of(context).size.width * .39),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width)),
                child: Icon(
                  Icons.account_circle_outlined,
                  size: MediaQuery.of(context).size.width * .18,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .75,
                left: MediaQuery.of(context).size.width * .365,
              ),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    width: MediaQuery.of(context).size.width * .25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal[300],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        // Onpressed right button code here

                        var x = login_credentials();
                        await x.login(
                            phone: widget.mobie_number, password: password);

                        await register_user();
                        //x.store(phone: '123444', password: 'trial');
                        Navigator.pop(context);

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => home()));
                      },
                      icon: Icon(
                        Icons.east,
                        color: Colors.white,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:Bencolites_Pannel/Home_activities/dashboard.dart';
import 'package:Bencolites_Pannel/Home_activities/discussion.dart';
import 'package:Bencolites_Pannel/Home_activities/search.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/login.dart';
import 'package:Bencolites_Pannel/down_stack_here/asset_profile_view.dart';
import 'package:Bencolites_Pannel/down_stack_here/create_post.dart';
import 'package:Bencolites_Pannel/main.dart';
import 'package:Bencolites_Pannel/profile_view_search/search_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'home_post_feed.dart';

Future image_url() async {
  var mobile = await login_credentials().getdata();
  var firestore = FirebaseFirestore.instance;
  var data = await firestore.collection("/users").doc(mobile).get();
  String url = data.data()["imageurl"];
  return url;
}

Future get_name() async {
  var mobile = await login_credentials().getdata();
  var firestore = FirebaseFirestore.instance;
  var data = await firestore.collection("/users").doc(mobile).get();
  String name = data.data()["name"];
  return name.toString();
}

List<Widget> text = [
  Text(
    'Home',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Search',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Discussion Pannel',
    style: TextStyle(color: Colors.black),
  ),
  Text(
    'Dashboard',
    style: TextStyle(color: Colors.black),
  )
];

class home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  final GlobalKey _scaffoldKey = new GlobalKey();
  double xoffset = 0;
  double yoffset = 0;
  double scalefactor = 1;
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  String title;
  String description;
  @override
  Widget build(BuildContext context) {
    List<Widget> body = [
      home_body(),
      search_body(),
      discussion_forum(),
      dashboard()
    ];
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.teal[500],
          child: Scaffold(
            backgroundColor: Colors.teal[500],
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .19,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      asset_logo_view()));
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          height: MediaQuery.of(context).size.height * .1,
                          width: MediaQuery.of(context).size.width * .17,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white, width: 2.0),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: AssetImage("images/logo.png"),
                                  fit: BoxFit.contain)),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "BENCOLITES PANNEL",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .596,
                  width: MediaQuery.of(context).size.width * .4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      create_post()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "New Post",
                              style: TextStyle(color: Colors.white),
                            ),
                            Expanded(child: Container()),
                            Icon(
                              Icons.post_add,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "See you post",
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(child: Container()),
                          Icon(
                            Icons.photo_album,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "About Developer",
                            style: TextStyle(color: Colors.white),
                          ),
                          Expanded(child: Container()),
                          Expanded(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              "About B.I.E.T. Unscripted",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                InkWell(
                  onTap: () async {
                    await login_credentials().logout();
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => login_ui()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 30, left: 10),
                    child: Text(
                      "Log out",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (scalefactor != 1) {
              setState(() {
                scalefactor = 1;
                xoffset = 0;
                yoffset = 0;
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            transform: Matrix4.translationValues(xoffset, yoffset, 0)
              ..scale(scalefactor),
            child: Scaffold(
              appBar: AppBar(
                title: text[_page],
                actions: _page == 1
                    ? [
                        IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          search_page()));
                            })
                      ]
                    : [],
                backgroundColor: Colors.teal[400],
                leading: IconButton(
                  icon: Icon(
                    Icons.calendar_view_day_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    if (scalefactor == 1) {
                      setState(() {
                        xoffset = MediaQuery.of(context).size.width * .4;
                        yoffset = MediaQuery.of(context).size.height * .2;
                        scalefactor = 0.6;
                      });
                    } else {
                      setState(() {
                        xoffset = 0;
                        yoffset = 0;
                        scalefactor = 1;
                      });
                    }
                  },
                ),
              ),
              body: ChangeNotifierProvider(
                  create: (context) => discussion_model(), child: body[_page]),
              bottomNavigationBar: CurvedNavigationBar(
                key: _bottomNavigationKey,
                index: 0,
                height: 50.0,
                items: <Widget>[
                  Icon(
                    Icons.home,
                    size: 30,
                  ),
                  Icon(
                    Icons.search,
                    size: 30,
                  ),
                  Icon(
                    Icons.chrome_reader_mode,
                    size: 30,
                  ),
                  Icon(
                    Icons.dashboard,
                    size: 30,
                  ),
                ],
                color: Colors.teal[300],
                buttonBackgroundColor: Colors.teal[300],
                backgroundColor: Colors.white.withOpacity(.4),
                animationCurve: Curves.easeInOut,
                animationDuration: Duration(milliseconds: 450),
                onTap: (index) async {
                  setState(() {
                    _page = index;
                  });
                },
              ),
              floatingActionButton: _page == 2
                  ? FloatingActionButton(
                      onPressed: () async {
                        var firestore = FirebaseFirestore.instance;
                        var mobile = await login_credentials().getdata();
                        var stat = await firestore
                            .collection('/users')
                            .doc(mobile)
                            .get();
                        bool status = await stat["adminstatus"];

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          child: status
                              ? AlertDialog(
                                  scrollable: true,
                                  title: Text('Create new Discussion'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: [
                                        TextField(
                                          onChanged: (e) {
                                            title = e;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Title',
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.greenAccent),
                                            ),
                                          ),
                                        ),
                                        TextField(
                                          maxLines: null,
                                          onChanged: (e) {
                                            description = e;
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Description',
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.greenAccent),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 20),
                                          child: GestureDetector(
                                            onTap: () async {
                                              bool st = true;
                                              String time =
                                                  DateTime.now().toString();

                                              Loader.show(context,
                                                  progressIndicator:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.teal[300]),
                                                  ));
                                              var docs = await firestore
                                                  .collection("/disucussion")
                                                  .get();

                                              for (var titlee in docs.docs) {
                                                if (titlee.id == title) {
                                                  st = false;
                                                }
                                              }
                                              String url = await image_url();
                                              String name = await get_name();
                                              String mobile =
                                                  await login_credentials()
                                                      .getdata();
                                              if (st) {
                                                await firestore
                                                    .collection('/disucussion')
                                                    .doc(title)
                                                    .set({
                                                  'description': description,
                                                  "imageurl": url,
                                                  "name": name,
                                                  "date": time
                                                });
                                                // await firestore
                                                //     .collection(
                                                //         "/disucussion/${title}/chats")
                                                //     .add({"hi": "hello"});
                                                // await firestore
                                                //     .collection(
                                                //         "/disucussion/${title}/chats")
                                                //     .add({"hsi": "hello"});
                                              }
                                              Loader.hide();

                                              //Navigator.pop(context);
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop('dialog');
                                              if (st == false) {
                                                showDialog(
                                                    context: context,
                                                    child: AlertDialog(
                                                      scrollable: true,
                                                      title: Text("Alert"),
                                                      content: Text(
                                                          "Discussion with same name already exist."),
                                                    ));
                                              }
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              color: Colors.teal[300],
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "CREATE",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : AlertDialog(
                                  title: Text(
                                      'Your Account is not an Admin account'),
                                  content: Container(
                                    height: 100,
                                    width: 100,
                                    child: IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                  ),
                                ),
                        );
                      },
                      backgroundColor: Colors.teal[300],
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

//Dashboard activity is container is here

// home body class is this

// Search body class here

// discussion pannel is here

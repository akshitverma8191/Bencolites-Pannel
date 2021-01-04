import 'dart:ui';

import 'package:Bencolites_Pannel/Home_activities/discussion_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class discussion_model extends ChangeNotifier {
  List heading;
  List description;
  int count = 1;
  List imageurls;
  List names;
  List date;

  Future get_discussions(context) async {
    var fire = FirebaseFirestore.instance;
    heading = [];
    description = [];
    names = [];
    imageurls = [];
    date = [];
    try {
      Loader.show(context,
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.white,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal[300]),
          ));
    } catch (e) {}

    var collec = await fire.collection('disucussion').get();
    for (var x in collec.docs) {
      heading.add(x.id);
      //description.add(x.get('description'));
      print('----------------------------');

      description.add(x.data()['description'].toString());
      imageurls.add(x.data()["imageurl"].toString());
      names.add(x.data()["name"].toString());
      date.add(x.data()["date"].toString());
      notifyListeners();
    }
    Loader.hide();
  }
}

class discussion_forum extends StatefulWidget {
  @override
  _discussion_forumState createState() => _discussion_forumState();
}

class _discussion_forumState extends State<discussion_forum> {
  var fire = FirebaseFirestore.instance;
  var x = 0;
  void discussionsion() async {
    var collec = await fire.collection('disucussion').get();
    setState(() {
      var x = collec.docs.length;
      print('x is here ------------------------------');
      print(x);
    });
  }

  Future messages(BuildContext context) async {
    await for (var snapshot in fire.collection('/disucussion').snapshots()) {
      var x = Provider.of<discussion_model>(context, listen: false);
      x.get_discussions(context);
      // for (var x in snapshot.docs) {
      //   print(x.data());
      // }
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    messages(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<discussion_model>(builder: (context, data, child) {
      return ListView.builder(
          itemCount: data.heading == null ? 1 : data.heading.length,
          itemBuilder: (context, index) {
            if (data.heading != null) {
              return Card(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .04,
                  right: MediaQuery.of(context).size.width * .04,
                  top: MediaQuery.of(context).size.width * .04,
                ),
                elevation: 6.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height * .15,
                  decoration: BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 5),
                            child: data.heading[index] != null
                                ? Text(
                                    data.heading[index],
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .05,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text('Loading'),
                          ),
                          Expanded(child: Container()),
                          Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Created by:\n${data.names[index]}\n${data.date[index]}",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(.6)),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10, left: 10),
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: data.imageurls[index] == null
                                        ? AssetImage("images/no_profile.jpg")
                                        : NetworkImage(data.imageurls[index]),
                                    fit: BoxFit.fill)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                        ),
                        child: Text(
                          'Description',
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * .025),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(left: 10, top: 3, bottom: 5),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: data.description[index] != null
                                  ? Text(
                                      data.description[index],
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .025,
                                          color: Colors.grey),
                                    )
                                  : Text('Loading'),
                            ),
                          ),
                          Expanded(child: Container()),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          discussion_chat(
                                            title: data.heading[index],
                                            description:
                                                data.description[index],
                                          )));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: 40, top: 10, bottom: 10),
                              height: 25,
                              width: 50,
                              child: Center(
                                  child: Text(
                                "Join",
                                style: TextStyle(color: Colors.white),
                              )),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.teal[300]),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .4,
                  ),
                  Text(
                    "Start New Discussion",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              );
            }
          });
    });
  }
}

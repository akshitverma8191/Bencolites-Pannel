import 'package:Bencolites_Pannel/Home_activities/dashboard.dart';
import 'package:Bencolites_Pannel/profile_view_search/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class search_data extends ChangeNotifier {
  List user_id;
  Map data_map;
  String nul;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future get_data() async {
    user_id = [];
    data_map = {};
    var doc = await firestore.collection("/users").get();
    for (var data in doc.docs) {
      user_id.add(data.id.toString());
      data_map[data.id] = data.data();
    }
    print(data_map);
    print(user_id);
    notifyListeners();
  }

  search_data() {
    get_data();
  }
}

class search_body extends StatefulWidget {
  @override
  _search_bodyState createState() => _search_bodyState();
}

class _search_bodyState extends State<search_body> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => search_data(),
      child: Consumer<search_data>(
        builder: (context, data, chil) {
          var trigger = Provider.of<search_data>(context, listen: false);
          //  trigger.get_data();
          if (data.user_id != null) {
            return GridView.builder(
                itemCount: data.user_id.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => profile_view(
                                    data: data.data_map,
                                    uid: data.user_id[index],
                                  )));
                    },
                    child: Container(
                      //padding: EdgeInsets.all(1),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 1)),
                      child: Column(
                        children: [
                          Expanded(
                              child: Stack(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20)),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "images/background.jpg"),
                                          fit: BoxFit.fill)),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(child: Container()),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1, color: Colors.white),
                                          image: data.data_map[data.user_id[index]]
                                                          ["imageurl"] ==
                                                      null ||
                                                  data.data_map[data.user_id[index]]
                                                          ["imageurl"] ==
                                                      ""
                                              ? DecorationImage(
                                                  image: AssetImage(
                                                      "images/no_profile.jpg"))
                                              : DecorationImage(
                                                  image: NetworkImage(
                                                      data.data_map[data.user_id[index]]["imageurl"]),
                                                  fit: BoxFit.contain)),
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                ],
                              ),
                            ],
                          )),
                          Expanded(
                              child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                    child: Center(
                                  child: Text(
                                    data.data_map[data.user_id[index]]["name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )),
                                Expanded(
                                    child: Container(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, bottom: 2),
                                  child: Center(
                                    child: Text(
                                      data.data_map[data.user_id[index]]
                                          ["about"],
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[300]),
              ),
            );
          }
        },
      ),
    );
  }
}

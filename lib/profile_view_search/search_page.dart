import 'package:Bencolites_Pannel/profile_view_search/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class search_page extends StatefulWidget {
  @override
  _search_pageState createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  String name;
  bool do_search = false;
  Map data_map = {};
  List uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future search(String name) async {
    var xl = await firestore
        .collection("/users")
        .where("casesearch_lower", arrayContains: name)
        .get();
    uid = [];
    for (var data in xl.docs) {
      data_map[data.id] = data.data();
      uid.add(data.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[400],
        title: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              onChanged: (e) async {
                await search(e.toLowerCase());
                if (e.length > 0) {
                  setState(() {
                    do_search = true;
                  });
                } else {
                  setState(() {
                    do_search = false;
                  });
                }
              },
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  hintText: "Enter Name",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black))),
            )),
        leading: IconButton(
            icon: Icon(
              Icons.cancel_sharp,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: do_search
          ? ListView.builder(
              itemCount: data_map.length > 0 ? uid.length : 1,
              itemBuilder: (context, index) {
                if (data_map.length > 0) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => profile_view(
                                      uid: uid[index],
                                      data: data_map,
                                    )));
                      },
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: data_map[uid[index]]["imageurl"] ==
                                            null ||
                                        data_map[uid[index]]["imageurl"] == ""
                                    ? DecorationImage(
                                        image:
                                            AssetImage("images/no_profile.jpg"))
                                    : DecorationImage(
                                        image: NetworkImage(
                                            data_map[uid[index]]["imageurl"]))),
                          ),
                          Text(
                            data_map[uid[index]]["name"],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text(
                            data_map[uid[index]]["about"],
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          )),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Text("No user found :("),
                    ),
                  );
                }
              })
          : Container(
              child: Center(
                child: Text("Search by Name"),
              ),
            ),
    );
  }
}

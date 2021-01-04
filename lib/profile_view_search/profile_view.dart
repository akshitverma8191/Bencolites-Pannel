import 'package:Bencolites_Pannel/Home_activities/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class profile_view extends StatefulWidget {
  String uid;
  Map data;
  List project_title;
  Map projects;

  profile_view({this.data, this.uid}) {
    project_title = [];
    projects = {};
    try {
      var x = (data[uid]["projects"]).keys;

      for (var key_title in x) {
        project_title.add(key_title.toString());
        projects[key_title] = data[uid]["projects"][key_title];
      }
    } catch (e) {}
  }
  @override
  _profile_viewState createState() => _profile_viewState();
}

class _profile_viewState extends State<profile_view> {
  List skills;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    skills = [];
    try {
      var ski = (widget.data[widget.uid]["skills"]).keys;
      for (var key in ski) {
        skills.add(key.toString());
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: GestureDetector(
                    onTap: () {
                      Map x = widget.data[widget.uid];
                      print(x["skills"]);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .20,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/background.jpg'),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .105,
                      left: MediaQuery.of(context).size.width * .075),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  profile_view_page(
                                    url: widget.data[widget.uid]["imageurl"],
                                  )));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .25,
                      height: MediaQuery.of(context).size.width * .25,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          shape: BoxShape.circle,
                          image: widget.data[widget.uid]["imageurl"] == null ||
                                  widget.data[widget.uid]["imageurl"] == ""
                              ? DecorationImage(
                                  image: AssetImage("images/no_profile.jpg"),
                                  fit: BoxFit.fill)
                              : DecorationImage(
                                  image: NetworkImage(
                                      widget.data[widget.uid]["imageurl"]),
                                  fit: BoxFit.fill)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, top: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),

            //About start
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .025,
                          ),
                          child: Text(
                            'About',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .025,
                      right: MediaQuery.of(context).size.width * .025,
                    ),
                    child: widget.data[widget.uid]["about"] == null
                        ? Text("",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic))
                        : Text(
                            widget.data[widget.uid]["about"],
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic),
                          ),
                  ),
                ],
              ),
            ),
            //About ends

            //Skills start
            Divider(
              color: Colors.black,
            ),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Skills',
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: skills.length > 0 ? skills.length : 1,
                          itemBuilder: (context, index) {
                            if (skills.length > 0) {
                              return Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                          child: Text(skills[index]))),
                                  RatingBar.builder(
                                      initialRating: widget.data[widget.uid]
                                          ["skills"][skills[index]],
                                      itemSize: 20,
                                      itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amberAccent,
                                          ),
                                      onRatingUpdate: null),
                                  Expanded(
                                    child: Container(),
                                  ),
                                ],
                              );
                            }
                          })
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),

            //Skills end
            //Projects start
            Divider(
              color: Colors.black,
            ),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .025),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Projects',
                        style: TextStyle(fontSize: 20),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                  Column(
                    children: [
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.project_title.length != null
                              ? widget.project_title.length
                              : 1,
                          itemBuilder: (context, index) {
                            if (widget.project_title.length != null) {
                              return Column(
                                children: [
                                  // All buttons for skill edit and delete are in row
                                  Row(
                                    children: [
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            widget.project_title[index],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .3,
                                        child: Text(
                                          widget.projects[
                                                  widget.project_title[index]]
                                                  ["startdate"]
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .3,
                                        child: Text(
                                          widget.projects[
                                                  widget.project_title[index]]
                                                  ["enddate"]
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.black
                                                  .withOpacity(0.7)),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .58,
                                        child: Text(widget.projects[
                                                widget.project_title[index]]
                                            ["description"]),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return Text("Add your projects");
                            }
                          }),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //projects end
          ],
        ),
      ),
    );
  }
}

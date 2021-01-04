import 'package:Bencolites_Pannel/Home_activities/discussion_chat.dart';
import 'package:Bencolites_Pannel/main.dart';
import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/login.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class dashboard_data_model extends ChangeNotifier {
  var firestore = FirebaseFirestore.instance;
  String url;
  String name;
  String batch;
  String about;
  List<Widget> skills = [CircularProgressIndicator()];
  List skills_keys = [];
  Map skill_map11 = {};
  Map projects = {};
  List project_headings = [];

  var login_cred = login_credentials();
  dashboard_data_model() {
    get_data();
    snapshot_subscription();
  }

  Future delete_project({String title_d}) async {
    var mobile = await login_cred.getdata();
    await firestore
        .collection("/users/${mobile}/projects")
        .doc(title_d)
        .delete();
    get_data();
  }

  Future update_project(
      {String title_u, String sdate_u, String edate_u, String desc_u}) async {
    var mobile = await login_cred.getdata();
    await firestore
        .collection("/users/${mobile}/projects")
        .doc(title_u)
        .delete();
    await firestore
        .collection("/users/${mobile}/projects")
        .doc(title_u)
        .set({"startdate": sdate_u, "enddate": edate_u, "description": desc_u});
    get_data();
  }

  Future add_projects(
      {String project_title,
      String start_date,
      String end_date,
      String description}) async {
    var mobile = await login_cred.getdata();
    firestore.collection("/users/${mobile}/projects").doc(project_title).set({
      "description": description,
      "startdate": start_date,
      "enddate": end_date
    });
    get_data();
  }

  Future edit_skill({Map skill_update_map}) async {
    var mobile = await login_cred.getdata();
    await firestore
        .collection('/users')
        .doc(mobile)
        .update({"skills": skill_update_map});
    get_data();
    notifyListeners();
  }

  Future add_skill({String skill, double rating}) async {
    var mobile = await login_credentials().getdata();
    var data = await firestore.collection('/users').doc(mobile).get();
    try {
      Map skill_map = await data["skills"];
      skill_map[skill] = rating;
      await firestore
          .collection('/users')
          .doc(mobile)
          .update({"skills": skill_map});
    } catch (e) {
      Map skill_map = {};
      skill_map[skill] = rating;
      await firestore
          .collection('/users')
          .doc(mobile)
          .update({"skills": skill_map});
    }
    notifyListeners();
    get_data();
  }

  Future about_({String about_in}) async {
    var mobile = await login_cred.getdata();
    var sub = firestore.collection('/users').doc(mobile).snapshots();
    try {
      var ab = await firestore
          .collection('/users')
          .doc(mobile)
          .update({"about": about_in});
      get_data();
    } catch (e) {}
  }

  Future get_data({BuildContext context}) async {
    var phone = await login_cred.getdata();
    var data = await firestore.collection('/users').doc(phone).get();
    var ur = await data['imageurl'];
    name = await data['name'];
    batch = await data['batch'];
    about = await data['about'];
    url = ur.toString();
    try {
      Map ski = await data["skills"];
      skill_map11 = {};
      skill_map11 = await data["skills"];
      skills = [];
      skills_keys = [];

      for (var key in ski.keys) {
        skills_keys.add(key.toString());
        Widget skill = Padding(
          padding: EdgeInsets.only(),
          child: Row(
            children: [
              Container(
                width: 150,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(),
                child: RatingBar.builder(
                    itemSize: 20,
                    initialRating: (ski[key]).toDouble(),
                    itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amberAccent,
                        ),
                    onRatingUpdate: null),
              ),
            ],
          ),
        );
        skills.add(skill);
      }
    } catch (e) {
      skills = [];

      skills.add(Text("Show your skills"));
    }
    // This code is to create new collection

    try {
      var docs = await firestore.collection("/users/${phone}/projects").get();
      project_headings = [];
      projects = {};

      for (var doc in docs.docs) {
        project_headings.add(doc.id);
        projects[doc.id] = doc.data();
      }
    } catch (e) {}

    notifyListeners();
  }

  Future snapshot_subscription({BuildContext context}) async {
    var mobile_no = await login_cred.getdata();
    await for (var snapshot
        in firestore.collection('/users').doc(mobile_no).snapshots()) {
      get_data();
    }
    var x = await firestore.collection('/users').doc(mobile_no).get();
    try {
      var y = x['imageurl'];

      url = y.toString();
    } catch (e) {}
    notifyListeners();
  }

  Future upload_image_and_url(BuildContext context, File image) async {
    var img_name = await login_cred.getdata();
    var firebasestorage =
        FirebaseStorage.instance.ref('profile_pics').child(img_name);
    var b = await firebasestorage.putFile(image);
    var ur = await firebasestorage.getDownloadURL();
    try {
      await firestore
          .collection('/users')
          .doc(img_name)
          .update({'imageurl': ur});
      url = ur;
      notifyListeners();
    } catch (e) {}
  }
}

class dashboard extends StatefulWidget {
  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  String data;
  File _image;
  final picker = ImagePicker();
  String url;
  String mobile_no;
  var fire = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => dashboard_data_model(),
      child: Consumer<dashboard_data_model>(
        builder: (context, data1, child) {
          Future getImage(ImageSource source_) async {
            final pickedFile = await picker.getImage(source: source_);

            if (pickedFile != null) {
              File croppedfile = await ImageCropper.cropImage(
                sourcePath: pickedFile.path,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                androidUiSettings: AndroidUiSettings(
                    toolbarTitle: 'Crop Profile Image',
                    toolbarColor: Colors.teal[300],
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false),
              );
              //  _image = File(pickedFile.path);
              var data_model =
                  Provider.of<dashboard_data_model>(context, listen: false);
              await data_model.upload_image_and_url(context, croppedfile);
            } else {
              print('No image selected.');
            }
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * .15,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/background.jpg'),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .075,
                          left: MediaQuery.of(context).size.width * .025),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      profile_view_page(
                                        url: data1.url,
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .24,
                          height: MediaQuery.of(context).size.width * .24,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: data1.url == null || data1.url == ''
                                    ? AssetImage('images/no_profile.jpg')
                                    : NetworkImage(data1.url),
                                fit: BoxFit.fill,
                              ),
                              border:
                                  Border.all(color: Colors.white, width: 5.0),
                              borderRadius: BorderRadius.circular(500)),
                          child: data1.url == null
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.teal[300]),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .175,
                          left: MediaQuery.of(context).size.width * .2),
                      child: IconButton(
                          icon: Icon(Icons.photo_camera),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                child: AlertDialog(
                                  content: Container(
                                    height: 100,
                                    width: 100,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                    icon: Icon(
                                                      Icons.photo_camera,
                                                      size: 50,
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await getImage(
                                                          ImageSource.camera);
                                                    }),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10, left: 10),
                                                  child: Text(
                                                    '   Camera',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.photo_album,
                                                    size: 50,
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await getImage(
                                                        ImageSource.gallery);
                                                  }),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10, left: 10),
                                                child: Text(
                                                  '   Gallery',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey),
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ));
                            //await getImage();
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .23,
                          left: MediaQuery.of(context).size.width * .025),
                      child: data1.name != null
                          ? Text(
                              data1.name,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .27,
                          left: MediaQuery.of(context).size.width * .025),
                      child: data1.batch != null
                          ? Text(
                              data1.batch,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                //About section starts here
                Divider(
                  color: Colors.black,
                ),
                Container(
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
                            Padding(
                              padding: EdgeInsets.only(),
                              child: IconButton(
                                  icon: Icon(Icons.create),
                                  onPressed: () {
                                    TextEditingController about_;
                                    about_ = TextEditingController(
                                        text: data1.about);

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      child: AlertDialog(
                                        scrollable: true,
                                        title: Text('About'),
                                        content: Container(
                                          child: Column(
                                            children: [
                                              TextField(
                                                maxLines: null,
                                                controller: about_,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  Loader.show(context,
                                                      progressIndicator:
                                                          CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(Colors
                                                                          .teal[
                                                                      300])));
                                                  await data1.about_(
                                                      about_in:
                                                          about_.text.trim());
                                                  Loader.hide();
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  alignment: Alignment.center,
                                                  width: double.maxFinite,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      color: Colors.tealAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: Center(
                                                    child: Icon(Icons.done),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .025,
                          right: MediaQuery.of(context).size.width * .025,
                        ),
                        child: data1.about == null
                            ? Text("Feel free to write",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic))
                            : Text(
                                data1.about,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic),
                              ),
                      ),
                    ],
                  ),
                ),
                //About section ends here

                //Skills Section Starts here
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
                          Padding(
                            padding: EdgeInsets.only(),
                            child: IconButton(
                              icon: Icon(
                                Icons.create,
                              ),
                              onPressed: () async {
                                //await data1.add_skill(skill: "Python");
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  child: AlertDialog(
                                      scrollable: true,
                                      title: Text("Edit Skills"),
                                      content: Column(
                                        children: [
                                          Container(
                                            height: 150,
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                                itemCount: data1.skills_keys
                                                            .length ==
                                                        1
                                                    ? 1
                                                    : data1.skills_keys.length,
                                                itemBuilder: (context, index) {
                                                  if (data1.skills_keys.length >
                                                      0) {
                                                    return Row(
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                              data1.skills_keys[
                                                                  index]),
                                                        ),
                                                        Expanded(
                                                          child: Container(),
                                                        ),
                                                        Center(
                                                          child:
                                                              RatingBar.builder(
                                                                  itemSize: 20,
                                                                  initialRating: data1
                                                                      .skill_map11[data1
                                                                          .skills_keys[
                                                                      index]],
                                                                  itemBuilder:
                                                                      (context,
                                                                              _) =>
                                                                          Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Colors.amberAccent,
                                                                          ),
                                                                  onRatingUpdate:
                                                                      (r) async {
                                                                    data1
                                                                        .skill_map11[data1
                                                                            .skills_keys[
                                                                        index]] = r;
                                                                  }),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed:
                                                                () async {
                                                              Loader.show(
                                                                  context,
                                                                  progressIndicator:
                                                                      CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation<
                                                                        Color>(Colors
                                                                            .teal[
                                                                        300]),
                                                                  ));
                                                              await data1
                                                                  .skill_map11
                                                                  .remove(data1
                                                                          .skills_keys[
                                                                      index]);
                                                              await data1.edit_skill(
                                                                  skill_update_map:
                                                                      data1
                                                                          .skill_map11);
                                                              Loader.hide();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  } else {
                                                    return Container(
                                                      child: Center(
                                                        child: Text(
                                                            "Please add skills first"),
                                                      ),
                                                    );
                                                  }
                                                }),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (data1.skills_keys.length >
                                                  0) {
                                                Loader.show(context,
                                                    progressIndicator:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.teal[300]),
                                                    ));
                                                await data1.edit_skill(
                                                    skill_update_map:
                                                        data1.skill_map11);
                                                Loader.hide();
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Container(
                                              width: double.maxFinite,
                                              height: 25,
                                              color: Colors.teal[300],
                                              child: Center(
                                                  child: Icon(Icons.done)),
                                            ),
                                          )
                                        ],
                                      )),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: data1.skills,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                String skill_name;
                                double rating = 1.0;
                                bool tick = false;

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    child: AlertDialog(
                                      title: Text("Add Skill"),
                                      content: Container(
                                        height: 150,
                                        child: Column(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(
                                                  hintText: 'Skill name'),
                                              onChanged: (e) {
                                                skill_name = e;
                                                if (e.length > 0) {
                                                  tick = true;
                                                } else {
                                                  tick = false;
                                                }
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            RatingBar.builder(
                                              initialRating: 1.0,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amberAccent,
                                              ),
                                              onRatingUpdate: (ratingg) {
                                                rating = ratingg;
                                              },
                                              itemSize: 25,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if (tick) {
                                                  Loader.show(context,
                                                      progressIndicator:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .teal[300]),
                                                      ));
                                                  await data1.add_skill(
                                                      rating: rating,
                                                      skill: skill_name);
                                                  Loader.hide();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Container(
                                                width: double.maxFinite,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    color: Colors.tealAccent),
                                                child: Center(
                                                    child: Icon(Icons.done)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                //Skills section ends here

                // Projects Section starts here
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
                          Padding(
                            padding: EdgeInsets.only(),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                              ),
                              onPressed: () async {
                                String start;
                                String end;
                                String description;
                                String title;

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    child: AlertDialog(
                                      scrollable: true,
                                      title: Text("Add project"),
                                      content: Column(
                                        children: [
                                          TextField(
                                            onChanged: (e) {
                                              title = e;
                                            },
                                            decoration: InputDecoration(
                                                hintText: "Project title"),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10, right: 5),
                                                      child: TextField(
                                                        onChanged: (e) {
                                                          start = e;
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                                hintText:
                                                                    "Start date"),
                                                        keyboardType:
                                                            TextInputType
                                                                .datetime,
                                                      ))),
                                              Expanded(
                                                  child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 5, right: 10),
                                                child: TextField(
                                                  onChanged: (e) {
                                                    end = e;
                                                  },
                                                  decoration: InputDecoration(
                                                      hintText: "End date"),
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                ),
                                              ))
                                            ],
                                          ),
                                          TextField(
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                hintText: "Enter description"),
                                            onChanged: (e) {
                                              description = e;
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (start.length > 0 &&
                                                  end.length > 0 &&
                                                  description.length > 0 &&
                                                  title.length > 0) {
                                                Loader.show(context,
                                                    progressIndicator:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.teal[300]),
                                                    ));
                                                await data1.add_projects(
                                                    project_title: title,
                                                    description: description,
                                                    start_date: start,
                                                    end_date: end);
                                                Loader.hide();
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10),
                                              height: 15,
                                              width: double.maxFinite,
                                              color: Colors.teal[200],
                                              child: Center(
                                                child: Icon(
                                                  Icons.done,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: data1.project_headings.length != null
                                  ? data1.project_headings.length
                                  : 1,
                              itemBuilder: (context, index) {
                                if (data1.project_headings.length != null) {
                                  return Column(
                                    children: [
                                      // All buttons for skill edit and delete are in row
                                      Row(
                                        children: [
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                data1.project_headings[index],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          Expanded(child: Container()),
                                          IconButton(
                                              icon: Icon(Icons.create),
                                              onPressed: () async {
                                                TextEditingController
                                                    title_controller;
                                                TextEditingController
                                                    start_date_controller;
                                                TextEditingController
                                                    end_date_controller;
                                                TextEditingController
                                                    description_controller;
                                                title_controller =
                                                    TextEditingController(
                                                        text: data1
                                                                .project_headings[
                                                            index]);
                                                start_date_controller =
                                                    TextEditingController(
                                                        text: data1.projects[
                                                                data1.project_headings[
                                                                    index]]
                                                                ["startdate"]
                                                            .toString());
                                                end_date_controller =
                                                    TextEditingController(
                                                        text: data1.projects[
                                                                data1.project_headings[
                                                                    index]]
                                                                ["enddate"]
                                                            .toString());
                                                description_controller =
                                                    TextEditingController(
                                                        text: data1
                                                            .projects[data1
                                                                .project_headings[
                                                            index]]["description"]);
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    child: AlertDialog(
                                                      scrollable: true,
                                                      title:
                                                          Text("Edit Project"),
                                                      content: Column(
                                                        children: [
                                                          TextField(
                                                            controller:
                                                                title_controller,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        start_date_controller,
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        end_date_controller,
                                                                  ),
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          TextField(
                                                            maxLines: null,
                                                            controller:
                                                                description_controller,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              Loader.show(
                                                                context,
                                                                progressIndicator:
                                                                    CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors.teal[
                                                                          300]),
                                                                ),
                                                              );
                                                              await data1.add_projects(
                                                                  description:
                                                                      description_controller
                                                                          .text
                                                                          .trim(),
                                                                  end_date:
                                                                      end_date_controller
                                                                          .text
                                                                          .trim(),
                                                                  start_date:
                                                                      start_date_controller
                                                                          .text
                                                                          .trim(),
                                                                  project_title:
                                                                      title_controller
                                                                          .text
                                                                          .trim());
                                                              Loader.hide();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 15),
                                                              color: Colors
                                                                  .teal[200],
                                                              width: double
                                                                  .maxFinite,
                                                              height: 15,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons.done,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ));
                                              }),
                                          IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  child: AlertDialog(
                                                    scrollable: true,
                                                    title: Text("Confirmation"),
                                                    content: Column(
                                                      children: [
                                                        Text(
                                                            "Are you sure you want to delete this?"),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  Container(),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            25),
                                                                child: Text(
                                                                  "No",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .greenAccent),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                Loader.show(
                                                                    context,
                                                                    progressIndicator:
                                                                        CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                      Colors.teal[
                                                                          300],
                                                                    )));
                                                                await data1.delete_project(
                                                                    title_d: data1
                                                                            .project_headings[
                                                                        index]);
                                                                Loader.hide();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            10),
                                                                child: Text(
                                                                  "Yes",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .greenAccent),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              })
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .3,
                                            child: Text(
                                              data1.projects[
                                                      data1.project_headings[
                                                          index]]["startdate"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.7)),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .3,
                                            child: Text(
                                              data1.projects[
                                                      data1.project_headings[
                                                          index]]["enddate"]
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .58,
                                            child: Text(data1.projects[data1
                                                    .project_headings[index]]
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
                // Projects Section ends here
              ],
            ),
          );
        },
      ),
    );
  }
}

class profile_view_page extends StatefulWidget {
  String url;
  profile_view_page({this.url}) {}
  @override
  _profile_view_pageState createState() => _profile_view_pageState();
}

class _profile_view_pageState extends State<profile_view_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        child: Center(
          child: widget.url == null || widget.url == ''
              ? Image(image: AssetImage('images/no_profile.jpg'))
              : Image(
                  image: NetworkImage(widget.url),
                ),
        ),
      ),
    );
  }
}

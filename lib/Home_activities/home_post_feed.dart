import 'dart:io';

import 'package:Bencolites_Pannel/Home_activities/dashboard.dart';
import 'package:Bencolites_Pannel/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class home_post_data_model extends ChangeNotifier {
  List session_headings;
  Map session_data;
  var firestore = FirebaseFirestore.instance;
  List post_feed;
  List post_feed_docs;
  Map img_url_name;
  home_post_data_model() {
    // get_session_data();
  }
  Future get_session_data() async {
    var x = await firestore.collection("biet_unscripted").get();
    session_data = {};
    List temp = [];
    session_headings = [];
    for (var data in x.docs) {
      temp.add(data.id);
      session_data[data.id] = data.data();
    }
    for (int i = 0; i < temp.length; i++) {
      session_headings.add(temp[temp.length - i - 1]);
    }
    //   get_post_feed();
    try {
      var x1 = await firestore.collection("posts").get();
      post_feed_docs = [];
      post_feed = [];
      img_url_name = {};
      for (var y in x1.docs) {
        post_feed_docs.add(y.id);
        post_feed.add(y.data());
        var tmp = await y.data()["userid"];
        var user_data = await firestore.collection("users").doc(tmp).get();
        img_url_name[y.id] = user_data;
        //post_feed[y.id] = y.data();
      }
    } catch (w) {
      print(w);
    }

    notifyListeners();
  }
}

class home_body extends StatefulWidget {
  @override
  _home_bodyState createState() => _home_bodyState();
}

class _home_bodyState extends State<home_body> {
  final picker = ImagePicker();

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
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.teal[300],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      );
      return croppedfile;
    } else {
      print('No image selected.');
    }
  }

  Future uplode_image_to_firestorage(File image) async {
    String img_name = DateTime.now().toString();

    var firebasestorage =
        FirebaseStorage.instance.ref("unscripted_images/").child(img_name);
    var b = await firebasestorage.putFile(image);
    var ur = await firebasestorage.getDownloadURL();
    return ur;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => home_post_data_model(),
      child: Consumer<home_post_data_model>(
        builder: (context, data, index) {
          var x = Provider.of<home_post_data_model>(context, listen: false);
          x.get_session_data();
          //x.get_post_feed();
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * .25,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.session_headings == null
                          ? 1
                          : data.session_data.length,
                      itemBuilder: (context, index) {
                        if (data.session_data != null) {
                          return Padding(
                            padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                            child: Card(
                              elevation: 6.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(color: Colors.black)),
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              show_session_photo(
                                                url: data.session_data[
                                                    data.session_headings[
                                                        index]]["imageurl"],
                                              )));
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  height:
                                      MediaQuery.of(context).size.height * .25,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 1),
                                      image: DecorationImage(
                                          image: data.session_data[data.session_headings[index]]
                                                          ["imageurl"] ==
                                                      null ||
                                                  data.session_data[data.session_headings[index]]
                                                          ["imageurl"] ==
                                                      ""
                                              ? AssetImage(
                                                  "images/unscripted.jpg")
                                              : NetworkImage(data.session_data[
                                                      data.session_headings[index]]
                                                  ["imageurl"]),
                                          fit: BoxFit.fill),
                                      borderRadius: BorderRadius.circular(25)),
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              var form_url =
                                                  await data.session_data[
                                                      data.session_headings[
                                                          index]]["googleform"];

                                              launch(form_url);
                                            },
                                            child: Text(
                                              "REGISTER HERE!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.tealAccent),
                                            ),
                                          ),
                                          Expanded(child: Container()),
                                          InkWell(
                                            onTap: () async {
                                              var form_url = await data
                                                      .session_data[
                                                  data.session_headings[
                                                      index]]["feedbackform"];

                                              launch(form_url);
                                            },
                                            child: Text(
                                              "FEEDBACK FORM!",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.tealAccent),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
                InkWell(
                  onLongPress: () async {
                    print("here it is");
                    // print(data.post_feed.keys);
                    var x = await FirebaseFirestore.instance
                        .collection("posts")
                        .get();
                    print(data.post_feed[0]["userid"]);
                  },
                  onTap: () async {
                    var firestore = FirebaseFirestore.instance;
                    var mobile = await login_credentials().getdata();
                    var stat =
                        await firestore.collection('/users').doc(mobile).get();
                    bool status = await stat["adminstatus"];
                    String google;
                    String feedback;
                    String date;
                    File image;
                    ImageSource imageSource = ImageSource.gallery;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      child: status
                          ? AlertDialog(
                              title: Text("Enter new session detials"),
                              scrollable: true,
                              content: Column(
                                children: [
                                  TextField(
                                    onChanged: (e) {
                                      google = e;
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Enter google form link"),
                                  ),
                                  TextField(
                                    onChanged: (e) {
                                      feedback = e;
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Enter feedback form link"),
                                  ),
                                  TextField(
                                    onChanged: (e) {
                                      date = e;
                                    },
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(fontSize: 10),
                                        hintText:
                                            "Enter date - YYYY-MM-DD format (Dont user /)"),
                                    keyboardType: TextInputType.name,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        image = await getImage(imageSource);
                                      },
                                      child: Container(
                                        width: double.maxFinite,
                                        color: Colors.blueGrey,
                                        height: 20,
                                        child: Center(
                                          child: Text("Add Image"),
                                        ),
                                      )),
                                  InkWell(
                                      onTap: () async {
                                        if (image != null &&
                                            google != null &&
                                            feedback != null) {
                                          Loader.show(context);
                                          String url =
                                              await uplode_image_to_firestorage(
                                                  image);
                                          await firestore
                                              .collection("biet_unscripted")
                                              .doc(date)
                                              .set({
                                            "feedbackform": feedback,
                                            "googleform": google,
                                            "imageurl": url
                                          });
                                          Loader.hide();
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        width: double.maxFinite,
                                        height: 20,
                                        child: Center(
                                          child: Text("Confirm"),
                                        ),
                                        color: Colors.tealAccent,
                                      ))
                                ],
                              ),
                            )
                          : AlertDialog(
                              title:
                                  Text('Your Account is not an Admin account'),
                              content: Container(
                                height: 100,
                                width: 100,
                                child: IconButton(
                                    icon: Icon(Icons.cancel),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ),
                            ),
                    );
                    print("hello");
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                    reverse: true,
                    itemCount: data.post_feed_docs == null
                        ? 1
                        : data.post_feed_docs.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (data.post_feed_docs != null) {
                        // print(data.post_feed);
                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(15)),
                          margin: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10),
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: data.img_url_name[data.post_feed_docs[index]]
                                                          ["imageurl"] ==
                                                      null ||
                                                  data.img_url_name[data
                                                              .post_feed_docs[
                                                          index]]["imageurl"] ==
                                                      ""
                                              ? AssetImage(
                                                  "images/no_profile.jpg")
                                              : NetworkImage(data.img_url_name[
                                                      data.post_feed_docs[index]]
                                                  ["imageurl"]),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    data.img_url_name[
                                        data.post_feed_docs[index]]["name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: data.post_feed[index]["text"] == null
                                    ? null
                                    : Text(data.post_feed[index]["text"]),
                              ),
                              Container(
                                //margin: EdgeInsets.all(10),
                                child: data.post_feed[index]["imageurl"] == null
                                    ? null
                                    : Image(
                                        image: NetworkImage(
                                            data.post_feed[index]["imageurl"]),
                                      ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    })
              ],
            ),
            scrollDirection: Axis.vertical,
          );
        },
      ),
    );
  }
}

// this is to show the photo of session
class show_session_photo extends StatefulWidget {
  String url;
  show_session_photo({this.url}) {}
  @override
  _show_session_photoState createState() => _show_session_photoState();
}

class _show_session_photoState extends State<show_session_photo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
            child: Image(
          image: widget.url == null || widget.url == ""
              ? AssetImage("images/unscripted.jpg")
              : NetworkImage(widget.url),
        )),
      ),
    );
  }
}

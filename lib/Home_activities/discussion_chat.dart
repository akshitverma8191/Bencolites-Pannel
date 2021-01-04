import 'dart:io';

import 'package:Bencolites_Pannel/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class chats_model extends ChangeNotifier {
  List date_doc;
  List map_data;
  String mobile;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future get_date(String title) async {
    var snapshot_sub =
        firestore.collection("/disucussion/${title}/chats").snapshots();
    //print(" change");
    mobile = await login_credentials().getdata();
    var n = await firestore.collection("/users").doc(mobile).get();

    try {
      var x = await firestore.collection("/disucussion/${title}/chats").get();
      date_doc = [];
      map_data = [];
      for (var y in x.docs) {
        date_doc.add(y.id);
        map_data.add(y.data());
        //   print(y.id);
        //  print(y.data());
        //  print(y.exists);
      }
      // print(map_data[0]["name"]);
      // print(date_doc);
    } catch (e) {}
    notifyListeners();
  }
}

class discussion_chat extends StatefulWidget {
  String title;
  String description;
  discussion_chat({this.description, this.title}) {}
  @override
  _discussion_chatState createState() => _discussion_chatState();
}

class _discussion_chatState extends State<discussion_chat> {
  TextEditingController message;
  var firestore = FirebaseFirestore.instance;
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => image_chat_screen(
                    image: croppedfile,
                    title: widget.title,
                  )));
      //  _image = File(pickedFile.path);
      //var data_model =
      //   Provider.of<chats_model>(context, listen: false);
      // await data_model.upload_image_and_url(context, croppedfile);
    } else {
      print('No image selected.');
    }
  }

  @override
  void initState() {
    message = TextEditingController(text: "");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => chats_model(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.teal[400],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                child: Consumer<chats_model>(
                  builder: (context, data, child) {
                    var chat_model =
                        Provider.of<chats_model>(context, listen: false);
                    chat_model.get_date(widget.title);
                    if (data.date_doc != null) {
                      ScrollController _controller = ScrollController(
                          initialScrollOffset: data.date_doc.length.toDouble() *
                              (data.date_doc.length) *
                              (data.date_doc.length));

                      return ListView.builder(
                          itemCount: data.date_doc.length,
                          controller: _controller,
                          itemBuilder: (context, index) {
                            if (data.mobile == data.map_data[index]["mobile"]) {
                              return Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Expanded(child: Container()),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            data.map_data[index]["name"],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Container(
                                            child: data.map_data[index]
                                                            ["photourl"] ==
                                                        "" ||
                                                    data.map_data[index]
                                                            ["photourl"] ==
                                                        null
                                                ? null
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                          context) =>
                                                                      see_image(
                                                                        url: data.map_data[index]
                                                                            [
                                                                            "photourl"],
                                                                      )));
                                                    },
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .4,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .2,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  data.map_data[
                                                                          index]
                                                                      [
                                                                      "photourl"]),
                                                              fit: BoxFit.fill),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                    ),
                                                  ),
                                          ),
                                          Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(20),
                                                    topLeft:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20))),
                                            elevation: 6.0,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors
                                                            .teal[200]),
                                                    color: Colors.teal[200],
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20))),
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      bottom: 2,
                                                      top: 1),
                                                  child: data.map_data[index]
                                                              ["message"] ==
                                                          null
                                                      ? null
                                                      : Text(
                                                          data.map_data[index]
                                                              ["message"],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                )),
                                          ),
                                          Text(
                                            data.date_doc[index],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      width: 15,
                                      height: 15,
                                      margin: EdgeInsets.only(right: 2),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: data.map_data[index]
                                                          ["imageurl"] ==
                                                      null
                                                  ? AssetImage(
                                                      "images/no_profile.jpg")
                                                  : NetworkImage(
                                                      data.map_data[index]
                                                          ["imageurl"]),
                                              fit: BoxFit.fill)),
                                    )
                                  ],
                                ),
                              );
                            }
                            // Row code for message from other side
                            else {
                              return Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      margin:
                                          EdgeInsets.only(right: 8, left: 2),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(data
                                                  .map_data[index]["imageurl"]),
                                              fit: BoxFit.fill)),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.map_data[index]["name"],
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Container(
                                          child: data.map_data[index]
                                                          ["photourl"] ==
                                                      "" ||
                                                  data.map_data[index]
                                                          ["photourl"] ==
                                                      null
                                              ? null
                                              : GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                see_image(
                                                                  url: data.map_data[
                                                                          index]
                                                                      [
                                                                      "photourl"],
                                                                )));
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .4,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .2,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                data.map_data[
                                                                        index][
                                                                    "photourl"]),
                                                            fit: BoxFit.fill),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                  ),
                                                ),
                                        ),
                                        Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          elevation: 6.0,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.blueGrey
                                                      .withOpacity(.1),
                                                  border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(.5)),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  20))),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    bottom: 2,
                                                    top: 1),
                                                child: data.map_data[index]
                                                            ["message"] ==
                                                        null
                                                    ? null
                                                    : Text(
                                                        data.map_data[index]
                                                            ["message"],
                                                        style: TextStyle(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .6),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                              )),
                                        ),
                                        Text(
                                          data.date_doc[index],
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          });
                    } else {
                      return Text("");
                    }
                  },
                ),
              ),
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 10, left: 10, top: 0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.grey),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                  maxLines: null,
                                  controller: message,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Type message here",
                                    focusedBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                  )),
                            ),
                            IconButton(
                                icon: Icon(Icons.perm_media),
                                onPressed: () {
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
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                          icon: Icon(
                                                            Icons.photo_camera,
                                                            size: 50,
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
                                                            await getImage(
                                                                ImageSource
                                                                    .camera);
                                                          }),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                left: 10),
                                                        child: Text(
                                                          '   Camera',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey),
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
                                                          Navigator.pop(
                                                              context);
                                                          await getImage(
                                                              ImageSource
                                                                  .gallery);
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
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10, left: 10, bottom: 5),
                    child: FloatingActionButton(
                      backgroundColor: Colors.teal[300],
                      onPressed: () async {
                        if (message.text.length > 0) {
                          String mess = message.text.trim();
                          message.clear();
                          await chats_model().get_date(widget.title);
                          String date = DateTime.now().toString();
                          String mobile = await login_credentials().getdata();
                          var data = await firestore
                              .collection("/users")
                              .doc(mobile)
                              .get();
                          String name = data.data()["name"];
                          String imageurl = data.data()["imageurl"];

                          await firestore
                              .collection("/disucussion/${widget.title}/chats")
                              .doc(date)
                              .set({
                            "message": mess,
                            "name": name,
                            "mobile": mobile,
                            "imageurl": imageurl,
                          });
                        }
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        // bottomNavigationBar: BottomAppBar(
        //   color: Colors.white,
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Container(
        //           margin: EdgeInsets.only(bottom: 20, left: 20),
        //           child: TextField(
        //             maxLines: null,
        //             keyboardType: TextInputType.multiline,
        //             decoration: InputDecoration(
        //                 focusedBorder: UnderlineInputBorder(
        //                     borderSide: BorderSide(color: Colors.teal[300]))),
        //           ),
        //         ),
        //       ),
        //       Padding(
        //         padding: EdgeInsets.only(right: 10, left: 10, bottom: 5),
        //         child: FloatingActionButton(
        //           backgroundColor: Colors.teal[300],
        //           onPressed: () {},
        //           child: Icon(
        //             Icons.send,
        //             color: Colors.black,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}

class image_chat_screen extends StatefulWidget {
  String title;
  File image;
  image_chat_screen({this.image, this.title}) {}
  @override
  _image_chat_screenState createState() => _image_chat_screenState();
}

class _image_chat_screenState extends State<image_chat_screen> {
  TextEditingController message;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    message = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
              child: Center(
            child: InteractiveViewer(
              child: Image(
                image: FileImage(widget.image),
              ),
            ),
          )),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 10, left: 10, top: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.teal[300]),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                                maxLines: null,
                                controller: message,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "Type message here",
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10, bottom: 5),
                  child: FloatingActionButton(
                    backgroundColor: Colors.teal[300],
                    onPressed: () async {
                      Loader.show(context,
                          progressIndicator: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.tealAccent),
                          ));
                      String mess;
                      String url;
                      if (message.text.length > 0) {
                        mess = message.text.trim();
                        message.clear();
                      }
                      String img_name = await login_credentials().getdata();
                      String time = DateTime.now().toString();
                      String img_id = time + img_name;
                      var firebasestorage = FirebaseStorage.instance
                          .ref("chat_images/${img_name}")
                          .child(img_id);
                      var b = await firebasestorage.putFile(widget.image);
                      var ur = await firebasestorage.getDownloadURL();
                      url = ur;

                      await chats_model().get_date(widget.title);
                      String date = DateTime.now().toString();
                      String mobile = await login_credentials().getdata();
                      var data = await firestore
                          .collection("/users")
                          .doc(mobile)
                          .get();
                      String name = data.data()["name"];
                      String imageurl = data.data()["imageurl"];

                      await firestore
                          .collection("/disucussion/${widget.title}/chats")
                          .doc(date)
                          .set({
                        "message": mess,
                        "name": name,
                        "mobile": mobile,
                        "imageurl": imageurl,
                        "photourl": url
                      });
                      Loader.hide();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class see_image extends StatefulWidget {
  String url;
  see_image({this.url}) {}
  @override
  _see_imageState createState() => _see_imageState();
}

class _see_imageState extends State<see_image> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        child: Center(
          child: Image(
            image: NetworkImage(widget.url),
          ),
        ),
      ),
    );
  }
}

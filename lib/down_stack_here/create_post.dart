import 'dart:io';

import 'package:Bencolites_Pannel/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class create_post extends StatefulWidget {
  @override
  _create_postState createState() => _create_postState();
}

class _create_postState extends State<create_post> {
  final picker = ImagePicker();
  File image;
  String text;
  String url;
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

  Future uplode_image_to_firestorage(File imag) async {
    String img_name = DateTime.now().toString();
    String mobile = await login_credentials().getdata();

    var firebasestorage =
        FirebaseStorage.instance.ref("post/${mobile}").child(img_name);
    var b = await firebasestorage.putFile(imag);
    var ur = await firebasestorage.getDownloadURL();
    return ur;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Post"),
        backgroundColor: Colors.teal[400],
        actions: [
          IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                Loader.show(context,
                    progressIndicator: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.teal[300]),
                    ));
                if (image != null) {
                  url = await uplode_image_to_firestorage(image);
                }
                var firestore = FirebaseFirestore.instance;
                String mob = await login_credentials().getdata();
                String time = DateTime.now().toString();
                await firestore.collection("posts").doc(time).set({
                  "text": text,
                  "imageurl": url,
                  "likes": 0,
                  "comments": {},
                  "userid": mob
                });
                await firestore
                    .collection("users")
                    .doc(mob)
                    .collection("mypost")
                    .doc(time)
                    .set({"ref": "posts/${time}"});

                Loader.hide();
                Navigator.pop(context);
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onChanged: (e) {
                text = e;
              },
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Write something here",
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(),
                ),
                Text("Add Photo"),
                IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () async {
                    File imagee = await getImage(ImageSource.gallery);
                    setState(() {
                      image = imagee;
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            Container(
              child: image == null
                  ? null
                  : Stack(
                      children: [
                        Image(image: FileImage(image)),
                        Row(
                          children: [
                            Expanded(child: Container()),
                            IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  size: 35,
                                  color: Colors.teal[300],
                                ),
                                onPressed: () {
                                  setState(() {
                                    image = null;
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

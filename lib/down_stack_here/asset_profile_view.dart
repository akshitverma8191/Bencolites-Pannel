import 'package:flutter/material.dart';

class asset_logo_view extends StatefulWidget {
  @override
  _asset_logo_viewState createState() => _asset_logo_viewState();
}

class _asset_logo_viewState extends State<asset_logo_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: InteractiveViewer(
              child: Image(
            image: AssetImage("images/logo.png"),
          )),
        ),
      ),
    );
  }
}

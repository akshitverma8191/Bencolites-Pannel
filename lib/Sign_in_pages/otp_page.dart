import 'package:Bencolites_Pannel/Home_activities/home.dart';
import 'package:Bencolites_Pannel/Sign_in_pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class mobile_otp extends StatefulWidget {
  String mobile_number;

  mobile_otp({this.mobile_number}) {}
  @override
  _mobile_otpState createState() => _mobile_otpState();
}

class _mobile_otpState extends State<mobile_otp> {
  // final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinputcontroller = TextEditingController();
  final BoxDecoration pinputdecoration = BoxDecoration(
    border: Border.all(
      color: Colors.teal[300],
      width: 5,
    ),
    borderRadius: BorderRadius.circular(10.0),
    color: Colors.teal[300].withOpacity(0.8),
  );
  final FocusNode _pinputfocusnode = FocusNode();

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.mobile_number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => home()),
                  (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    // TODO: implement initState
    _verifyPhone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
              child: CircleAvatar(
                backgroundColor: Colors.teal[300],
                radius: MediaQuery.of(context).size.height * .1,
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.height * .1,
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height * .1),
              child: Container(
                //width: MediaQuery.of(context).size.width * .6,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1,
                      right: MediaQuery.of(context).size.width * .1),
                  // child: TextField(
                  //   //ONchange number save here
                  //   onSubmitted: (t) {
                  //     // ################## on changed grab otp from here
                  //   },
                  //   decoration: InputDecoration(
                  //     icon: Icon(Icons.message),
                  //     hintText: 'Enter OTP',
                  //     focusedBorder: UnderlineInputBorder(
                  //       borderSide: BorderSide(color: Colors.teal[300]),
                  //     ),
                  //   ),
                  // ),
                  child: PinPut(
                    fieldsCount: 6,
                    textStyle:
                        const TextStyle(fontSize: 25.0, color: Colors.white),
                    eachFieldWidth: 40.0,
                    eachFieldHeight: 55.0,
                    focusNode: _pinputfocusnode,
                    controller: _pinputcontroller,
                    submittedFieldDecoration: pinputdecoration,
                    selectedFieldDecoration: pinputdecoration,
                    followingFieldDecoration: pinputdecoration,
                    pinAnimationType: PinAnimationType.fade,
                    onSubmit: (pin) async {
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode,
                                smsCode: pin))
                            .then((value) async {
                          if (value.user != null) {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => register(
                                          mobie_number: widget.mobile_number,
                                        )),
                                (route) => false);
                          }
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .1,
                left: MediaQuery.of(context).size.width * .09,
                right: MediaQuery.of(context).size.width * .09,
              ),
              child: GestureDetector(
                onTap: () {
                  // ############## here opt verification code will come up
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (BuildContext context) => register()));
                  print(widget.mobile_number);
                  print(_pinputcontroller.text);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.teal[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * .1,
                  child: Center(
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

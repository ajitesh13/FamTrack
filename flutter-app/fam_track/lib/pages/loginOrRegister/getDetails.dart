import 'dart:async';
import 'dart:developer';

import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/trackeeInfo.dart';
import 'package:famtrack/pages/homeScreen/homeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GetDetails extends StatefulWidget{
  static final String id = "getDetails";
  GetDetails({Key key}) : super(key:key);

  GetDetailsState createState() => GetDetailsState();
}

class GetDetailsState extends State<GetDetails>{

  static String email = "";
  static String image = "";
  File _image;
  final picker = ImagePicker();
  static String selectImageString = "Click here to select a picture";
  static double errorOpacity = 0.0;
  static bool isProgressOffStaged = true;
  static String errorMessage = "ERROR : ";
  static String username = "";
  static String password = "";

  onSubmitClicked(){
    if(!EmailValidator.validate(email)){
      setState(() {
        errorMessage = "Email enterted is incorrect";
        errorOpacity = 1.0;
        isProgressOffStaged = true;
      });
    }
    else if(image == ""){
      setState(() {
        errorMessage = "No image is selected";
        errorOpacity = 1.0;
        isProgressOffStaged = true;
      });
    }
    else{
      setState(() {
        errorOpacity = 0.0;
        isProgressOffStaged = false;
      });
      //Register User
      http.Response response;
      registerUser().then((value){
        response = new http.Response(value.body, value.statusCode);
        try{
          var rJson = jsonDecode(response.body);
          String userId = rJson["_id"];
          saveUserId(userId);
          log(userId);
          //get the user's data
          TrackeeInfo.loadTrackeeInfo(userId).then((value){
            log("And we have returned!!");
            isProgressOffStaged = true;
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Home(),
                  transitionDuration: Duration(seconds: 1),
                  transitionsBuilder: (context, animation1, animation2, child){
                    var opacityAnim = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    );
                    var anim = animation1.drive(opacityAnim);
                    return FadeTransition(
                      child: child,
                      opacity: anim,
                    );
                  },
                )
            );
          });
        }
        catch(e){
          log("Same User Already Exists");
          setState(() {
            errorMessage = "An error occured, try again !";
            errorOpacity = 1.0;
            isProgressOffStaged = true;
          });
        }
      });
      saveSharedPrefs();
    }
  }

  Future<http.Response> registerUser(){
    String getUserLink = DotEnv().env['SERVER_LINK']+'api/getuser/';
    http.post(getUserLink);
    String endPoint = DotEnv().env['SERVER_LINK']+'api/register/';
    return http.post(
      endPoint,
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name' : username,
        'email' : email,
        'password' : password,
        'image' : image,
      }),
    );
  }

  Future saveUserId(String userUniqueId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userUniqueId', userUniqueId);
  }

  Future saveSharedPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userImage', image);
    prefs.setString('userEmail', email);
  }

  Future loadSharedPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.get('userId');
    password = prefs.get('userPassword');
  }

  Future cropImage(String path) async{
    _image = await ImageCropper.cropImage(sourcePath: path, aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), maxHeight: 500, maxWidth: 500);
    final bytes = _image.readAsBytesSync();
    setState(() {
      selectImageString = "Done.. Click to select new";
      image = base64Encode(bytes);
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        cropImage(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context)?.size?.width;
    loadSharedPrefs();
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/images/family_splash.png'),
                          width: screenWidth/4,
                        ),
                        Text(
                            MyStrings.appName,
                            style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.primaryAccent ,fontWeight: FontWeight.bold, fontSize: 35)
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 30),
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        "Let's add a personal touch",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(color: MyColors.primaryAccent)
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primaryAccent,),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            child: Text(
                              "Enter your email",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            child: Material(
                              color: Colors.transparent,
                              child: TextField(
                                style: TextStyle(
                                  fontSize: 17, color: MyColors.primaryAccent,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter mail here !",
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryAccent)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryAccent)),
                                  hintStyle: TextStyle(
                                    fontSize: 15, color: MyColors.primaryAccent,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                                cursorColor: MyColors.primaryAccent,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value)=> email = value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primaryAccent,),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            child: Text(
                              "Select a picture of yours",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            decoration: BoxDecoration(
                              border: Border.all(color: MyColors.primaryAccent),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: RaisedButton(
                              color: Colors.transparent,
                              child: Text(
                                selectImageString,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyColors.primaryAccent),
                              ),
                              onPressed: getImage,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primaryAccent),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: RaisedButton(
                        color: Colors.transparent,
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyColors.primaryAccent),
                        ),
                        onPressed: onSubmitClicked,
                        elevation: 0,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    AnimatedOpacity(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.primaryAccent,),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Text(
                            errorMessage,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ),
                      opacity: errorOpacity,
                      duration: Duration(milliseconds: 200),
                    )
                  ],
                )

            ),
            Positioned.fill(
              child: Offstage(
                child: Stack(
                  children: <Widget>[
                    SizedBox.expand(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MyColors.secondaryAccent.withOpacity(0.5),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: MyColors.secondaryAccent,
                        valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryAccent),
                        strokeWidth: 4,
                      ),
                    ),
                  ],
                ),
                offstage: isProgressOffStaged,
              )
            ),
          ],
        )
      ),
    );
  }

}
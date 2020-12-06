import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/pages/homeScreen/homeScreen.dart';
import 'package:famtrack/pages/loginOrRegister/loginScreen.dart';

class SplashScreen extends StatefulWidget {
  static String id="splash_page";
  SplashScreen({Key key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isUserLoggedIn = false;
    var landingScreen;
    if(isUserLoggedIn){
      landingScreen = Home();
    }
    else{
      landingScreen = Login();
    }

    Image famImg = Image(
      image: AssetImage('assets/images/family_splash.png'),
    );

    Timer(
      Duration(seconds: 4),
      () =>
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => landingScreen)
        )
    );

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              famImg,
              Text(
                MyStrings.appName,
                style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.primaryAccent ,fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
    );
  }
}
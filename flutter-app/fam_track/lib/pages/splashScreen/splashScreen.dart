import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:famtrack/global/trackeeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/pages/homeScreen/homeScreen.dart';
import 'package:famtrack/pages/loginOrRegister/loginScreen.dart';
import 'package:famtrack/global/myLoc.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static String id="splash_page";
  SplashScreen({Key key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{

  String myUserId = "";

  Future loadSharedPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.get('userUniqueId');
  }

  @override
  void initState() {
    super.initState();
    loadSharedPrefs().then((value){
//      myUserId = "";
      if(myUserId != "" && myUserId!=null){
        TrackeeInfo.loadTrackeeInfo(myUserId).then((value){
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => Home(),
                transitionDuration: Duration(seconds: 2),
                transitionsBuilder: (context, animation1, animation2, child) {
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
      else{
        Timer(
            Duration(seconds: 4), () {
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => Login(),
                  transitionDuration: Duration(seconds: 0)
              )
          );
        });
      }
    });

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void setCurrPos(){
    _determinePosition().then((value)
    {
        MyLoc.setMyLoc(value.latitude, value.longitude);
    });
  }

//  void setTrackeeInfo(){
//    double radius = 0.008;
//    TrackeeInfo.trackees = new List<TI>();
//    for(int i = 1; i< 10; i++){
//      TI t = new TI();
//      t.loc = new LatLng(MyLoc.getMyLoc().latitude - i * 0.03, MyLoc.getMyLoc().longitude + i * 0.03);
//      t.imageAsset = AssetImage("assets/images/family_splash.png");
//      t.name = "Ridham"+i.toString();
//      t.safeLoc.add(MyLoc.getMyLoc());
//      t.safeLoc.add(t.loc);
//      for(LatLng tl in t.safeLoc){
//        if(pow((t.loc.latitude - tl.latitude),2.0) + pow((t.loc.longitude - tl.longitude),2.0) < pow(radius,2.0))
//          t.isInSafeLocation = true;
//      }
//      TrackeeInfo.trackees.add(t);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    var isUserLoggedIn = false;

    Image famImg = Image(
      image: AssetImage('assets/images/family_splash.png'),
      width: 400,
    );

    setCurrPos();
//    setTrackeeInfo();

    return Scaffold(
        backgroundColor: MyColors.primaryColor,
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
import 'dart:developer';

import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/trackeeInfo.dart';
import 'package:famtrack/pages/familyCard/fullPageAddLocation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyCard extends StatefulWidget {
  static String id = "family_card";

  @override
  _FamilyCardState createState() => _FamilyCardState();
}

class _FamilyCardState extends State<FamilyCard>{

  TI cardValue = new TI();
  static int index;
  MapController controller = new MapController();
  List<Marker> mapMarkers = new List<Marker>();
  bool shouldAddNewSafeLoc = false;

  void buildMarkers(){
    mapMarkers = new List<Marker>();
    int i = 0;
    for (LatLng lc in cardValue.safeLoc) {
      mapMarkers.add(
          Marker(
              width: 60,
              height: 60,
              point: lc,
              builder: (context) =>
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColors.safeGreen,
                    ),
                  )
          )
      );
    }
    mapMarkers.add(Marker(
      width: 60, height: 60, point: cardValue.loc,
      builder: (context) => Container(
        child: Icon(
          Icons.my_location,
          color: MyColors.primaryAccent,
        ),
      )
    ));
  }

  _navigateToNextScreen(BuildContext context) async{
    log("name => "+TrackeeInfo.trackees[index].name+" Pressed");
    final result = await Navigator.pushNamed(context, FullPageAddLocation.id, arguments: index);
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    index = ModalRoute.of(context).settings.arguments;
    Image famImg = Image(image: AssetImage('assets/images/family_splash.png'));
    cardValue = TrackeeInfo.trackees[index];
    if(mapMarkers.length <= cardValue.safeLoc.length)
      buildMarkers();
    log(cardValue.name + "Entered");
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryAccent,
        centerTitle: true,
        title: Text(
          MyStrings.appName,
          style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.primaryColor ,fontWeight: FontWeight.bold, fontSize:35),
          textAlign: TextAlign.center,
        ),
        leading: Container(
          child: famImg,
          margin: EdgeInsets.only(left: 15),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Hero(
                tag: 'famCard'+index.toString(),
                child: AspectRatio(
                  child: Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: TrackeeInfo.trackees[index].imageAsset,
                      ),
                    ),
                  ),
                  aspectRatio: 1,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Text(
                      cardValue.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'montserrat', color: MyColors.primaryAccent),
                    ),
                    FlatButton(
                      child: Text(
                        shouldAddNewSafeLoc ? "Add This Place" : "Re-Center",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'montserrat', color: MyColors.secondaryAccent),
                      ),
                      color: MyColors.primaryAccent,
                      onPressed: (){
                        if(shouldAddNewSafeLoc){
                          //SendRequestForAdding
                          TrackeeInfo.trackees[index].safeLoc.add(controller.center);
                          setState(() {
                            mapMarkers.add(
                                Marker(
                                    width: 60,
                                    height: 60,
                                    point: controller.center,
                                    builder: (context) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: MyColors.safeGreen,
                                          ),
                                        )
                                )
                            );
                          });
                        }
                        else{
                          controller.move(cardValue.loc, 13);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(
                        shouldAddNewSafeLoc ? "Go Back To Viewing" : "Add new Safe Location",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'montserrat', color: MyColors.secondaryAccent),
                      ),
                      color: MyColors.primaryAccent,
                      onPressed: (){
                        if(shouldAddNewSafeLoc){
                          setState(() {
                            shouldAddNewSafeLoc = false;
                          });
                        }
                        else{
                          setState(() {
                            shouldAddNewSafeLoc = true;
                          });
                        }
                      },
                    )
                  ],
                ),
              )
            ),
            Expanded(
              flex: 8,
              child: Hero(
                tag: "FullScreenMap"+index.toString(),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: FlutterMap(
                        mapController: controller,
                        options: MapOptions(
                          center: cardValue.loc,
                          zoom: 13,
                        ),
                        layers: [
                          TileLayerOptions(
                              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a','b','c']
                          ),
                          MarkerLayerOptions(
                              markers: mapMarkers
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: MyColors.primaryColor,
                        ),
                        child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "© ",
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextSpan(
                                    text: "OpenStreetMap",
                                    style: TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()..onTap = (){
                                      launch('https://www.openstreetmap.org/copyright');
                                    }
                                ),
                                TextSpan(
                                  text: " contributors",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ]
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.location_on, color: shouldAddNewSafeLoc ? Color.fromRGBO(200, 0, 0, 1):Color.fromRGBO(255, 0, 0, 0),),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        child: FlatButton(
                          child: Icon(
                            Icons.fullscreen, color:MyColors.primaryAccent,size: 50,
                          ),
                          color: Colors.transparent,
                          onPressed: (){
                            _navigateToNextScreen(context);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}




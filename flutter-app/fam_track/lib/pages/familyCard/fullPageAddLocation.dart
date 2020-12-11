import 'dart:convert';
import 'dart:developer';

import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/trackeeInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FullPageAddLocation extends StatefulWidget {
  static String id = "full_page_add_location";

  @override
  _FullPageAddLocationState createState() => _FullPageAddLocationState();
}

class _FullPageAddLocationState extends State<FullPageAddLocation>{

  TI cardValue = new TI();
  static int index;
  MapController controller = new MapController();
  List<Marker> mapMarkers = new List<Marker>();
  bool shouldAddNewSafeLoc = false;
  static String placeName = "";
  bool isLoadingOffStaged = true;

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

  Future<bool> _onWillPop() async{
    Navigator.pop(context, true);
    return true;
  }

  Future<LatLng> fetchLatLong(String link) async{
    log(link);
    final response = await http.get(link);
    LatLng ret = new LatLng(0.0, 0.0);
    if(response.statusCode == 200){
      log(response.body);
      try{
        var d = jsonDecode(response.body);
        var results = d['results'];
        if (results != null) {
          var loc = results[0]["locations"][0]["latLng"];
          ret = new LatLng(loc["lat"], loc["lng"]);
        }
      }
      catch(e){
        return ret;
      }
    }
    return ret;
  }

  void searchPlace(){
    String link = "http://open.mapquestapi.com/geocoding/v1/address?key="+DotEnv().env['GEOCODING_API_2']+"&location=";
    var words = placeName.split(' ');
    for(String str in words){
      link=link+str+"%20";
    }
    if(placeName.length > 1) {
      setState(() {
        isLoadingOffStaged = false;
      });
      fetchLatLong(link).then((value) {
        if (value.latitude != 0.0 && value.longitude != 0.0){
          controller.move(value, 13);
        }
        setState(() {
          isLoadingOffStaged = true;
        });
      });
    }
  }

  void onSubmitClicked(){
    setState(() {
      isLoadingOffStaged = false;
    });
    LatLng centerLoc = controller.center;
    addSafePlace(centerLoc.latitude.toString(), centerLoc.longitude.toString()).then((value){
      try{
        var retJson = jsonDecode(value.body);
        String success = retJson["msg"];
        if(success == "location saved"){
          TrackeeInfo.trackees[index].safeLoc.add(centerLoc);
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
            isLoadingOffStaged = true;
          });
        }
        else{
          anErrorOccurred();
        }
      }
      catch(e){
        anErrorOccurred();
      }
    });

  }

  void anErrorOccurred(){
    setState((){
      isLoadingOffStaged = true;
    });
  }

  Future<http.Response> addSafePlace(String lat, String long) async{
    String getUserLink = DotEnv().env['SERVER_LINK'] + 'api/savelocation/';
    http.post(getUserLink);
    String endPoint = getUserLink;
    return http.post(
      endPoint,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id' : cardValue.uniqueUserId,
        'Saved_location' : [
          {
            'latitude' : lat,
            'longitude' : long
          }
        ]
      }),
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context)?.size?.width;
    index = ModalRoute.of(context).settings.arguments;
    Image famImg = Image(image: AssetImage('assets/images/family_splash.png'));
    cardValue = TrackeeInfo.trackees[index];
    if(mapMarkers.isEmpty)
      buildMarkers();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: MyColors.primaryColor,
        resizeToAvoidBottomInset: false,
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
        body: Stack(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: Hero(
                      tag: "FullScreenMap"+index.toString(),
                      child: Stack(
                        alignment: Alignment.center,
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
                          Positioned(
                            bottom: 20,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      shouldAddNewSafeLoc ? "Add This Place" : "Re-Center",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'montserrat', color: MyColors.secondaryAccent),
                                    ),
                                    color: MyColors.primaryAccent,
                                    onPressed: (){
                                      if(shouldAddNewSafeLoc){
                                        //SendRequestForAdding
                                        onSubmitClicked();
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
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 30,
                            right: 30,
                            child: Container(
                                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                                decoration: BoxDecoration(
                                    color: MyColors.primaryAccent,
                                    borderRadius: BorderRadius.all(Radius.circular(20))
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width: screenWidth - 170,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: new TextField(
                                            style: TextStyle(
                                              fontSize: 17, color: MyColors.primaryColor,
                                            ),
                                            decoration: InputDecoration(
                                                hintText: "Search for places here !",
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                  fontSize: 15, color: MyColors.primaryColor,
                                                )
                                            ),
                                            onChanged: (value)=>placeName = value,
                                            onSubmitted: (value){
                                              searchPlace();
                                            },
                                          ),
                                        )
                                    ),
                                    Container(
                                      width: 70,
                                      child: FlatButton.icon(
                                        icon: Icon(
                                          Icons.search, color: MyColors.primaryColor, size: 25,
                                        ),
                                        label: Text("", style: TextStyle(fontSize: 1),),
                                        color: Colors.transparent,
                                        onPressed: (){
                                          FocusScope.of(context).unfocus();
                                          searchPlace();
                                        },
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              child: FlatButton(
                                child: Icon(
                                  Icons.my_location, color:MyColors.primaryAccent,size: 50,
                                ),
                                color: Colors.transparent,
                                onPressed: (){
                                  controller.move(cardValue.loc, 13);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
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
                  offstage: isLoadingOffStaged,
                )
            ),
          ],
        )
      ),
    );
  }
}




import 'dart:async';
import 'dart:developer' as d;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:famtrack/global/myLoc.dart';


class TrackeeInfo{
  static List<TI> trackees = new List<TI>();

  static Future<dynamic> loadTrackeeInfo(String id) async{
    trackees = new List<TI>();
    try{
      await getUser(id).then((value) async {
        http.Response gtlRes = new http.Response(value.body, value.statusCode);
        try{
          d.log("Got The User Info");
          var rJson = jsonDecode(gtlRes.body);
          var tlist = rJson["Trackee"];
          String myImg64 = rJson["image"];
          MyLoc.setMyImage(base64Decode(myImg64));



          for(var te in tlist){
            String trackeeId = te["Trackee_id"];
            if(trackeeId == "")
              continue;
            try{
              await getUser(trackeeId).then((mainValue){
                http.Response trackeeRes = new http.Response(mainValue.body, mainValue.statusCode);
                try{
                  d.log("Got trackee info | id => "+trackeeId);
                  var trJson = jsonDecode(trackeeRes.body);
                  String name = trJson["name"];
                  String email = trJson["email"];
                  String image64 = trJson["image"];
                  var savedLoc = trJson["saved_location"];
                  TI tempT = new TI();
                  tempT.name = name;
                  tempT.email = email;
                  tempT.imageAsset = new MemoryImage(base64Decode(image64));
                  tempT.safeLoc.add(MyLoc.getMyLoc());
                  tempT.uniqueUserId = trackeeId;
                  d.log("Before random");
                  Random random = new Random();
                  double r1 = (random.nextInt(50)+25)/1000 * ((random.nextInt(4)%2==0)?1:-1);
                  double r2 = (random.nextInt(50)+25)/1000 * ((random.nextInt(4)%2==0)?1:-1);
                  tempT.loc = new LatLng(MyLoc.getMyLoc().latitude + r1, MyLoc.getMyLoc().longitude + r2);
                  tempT.safeLoc.add(tempT.loc);
                  double radius = 0.008;
                  for(var sl in savedLoc){
                    if(sl["latitude"]=="")
                      continue;
                    tempT.safeLoc.add(new LatLng(double.parse(sl["latitude"]), double.parse(sl["longitude"])));
                  }
                  for(LatLng tl in tempT.safeLoc){
                    if(pow((tempT.loc.latitude - tl.latitude),2.0) + pow((tempT.loc.longitude - tl.longitude),2.0) < pow(radius,2.0))
                      tempT.isInSafeLocation = true;
                  }
                  trackees.add(tempT);
                  d.log("length => "+trackees.length.toString());
                }
                catch(e){
                  return;
                }
              });
            }
            catch(e){
              return;
            }
          }
        }
        catch(e){
          return;
        }
      });
    }
    catch(e){
      return false;
    }
  }

  static Future<http.Response> getUser(String userUniqueId) {
    String getUserLink = DotEnv().env['SERVER_LINK'] + 'api/getuser/';
    http.post(getUserLink);
    String endPoint = getUserLink;
    return http.post(
      endPoint,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': userUniqueId
      }),
    );
  }

}

class TI{
  LatLng loc;
  String name;
  String email;
  String uniqueUserId;
  MemoryImage imageAsset;
  List<LatLng> safeLoc = new List<LatLng>();
  bool isInSafeLocation = false;
}
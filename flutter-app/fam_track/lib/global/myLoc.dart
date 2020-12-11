import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class MyLoc{
  static LatLng _myLoc = new LatLng(0, 0);
  static MemoryImage _myimg;

  static void setMyLoc(double lat, double long)
  {
    _myLoc = new LatLng(lat, long);
  }

  static LatLng getMyLoc(){
    LatLng copyLoc = new LatLng(_myLoc.latitude, _myLoc.longitude);
    return copyLoc;
  }

  static void setMyImage(bytes){
    _myimg = new MemoryImage(bytes);
  }

  static MemoryImage getMyImage(){
    return _myimg;
  }
}
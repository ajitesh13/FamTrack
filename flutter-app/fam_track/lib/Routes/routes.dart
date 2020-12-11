import 'package:famtrack/pages/familyCard/familyCard.dart';
import 'package:famtrack/pages/familyCard/fullPageAddLocation.dart';
import 'package:famtrack/pages/loginOrRegister/getDetails.dart';
import 'package:famtrack/pages/loginOrRegister/loginScreen.dart';
import 'package:famtrack/pages/homeScreen/homeScreen.dart';

class Routes{
  static final routes = {
    Login.id: (context)=> Login(),
    GetDetails.id: (context) => GetDetails(),
    Home.id: (context)=> Home(),
    FamilyCard.id: (context) => FamilyCard(),
    FullPageAddLocation.id: (context) => FullPageAddLocation(),
  };
}
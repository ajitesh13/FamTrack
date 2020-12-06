import 'package:flutter/material.dart';
import 'package:famtrack/pages/splashScreen/splashScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'FamTrack',
        theme: ThemeData(fontFamily: 'montserrat'),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: {},
      ),
    );
  }
}
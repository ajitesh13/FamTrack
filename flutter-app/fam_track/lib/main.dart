import 'package:flutter/material.dart';
import 'package:famtrack/pages/splashScreen/splashScreen.dart';
import 'package:famtrack/Routes/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{

  Future main() async {
    await DotEnv().load('.env');
  }

  @override
  Widget build(BuildContext context) {
    main();
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
        routes: Routes.routes,
      ),
    );
  }
}
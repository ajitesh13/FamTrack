import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/trackeeInfo.dart';
import 'package:famtrack/pages/homeScreen/homeScreen.dart';
import 'package:famtrack/pages/loginOrRegister/getDetails.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Login extends StatefulWidget {
  static String id = "login_page";

  Login({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class LoginData{
  String username = "";
  String password = "";
}

class _RegisterState extends State<Login> {

  bool imageAnim = false;
  double titleOpacity = 0;
  bool isLoginSelected = true;
  final _formKey = GlobalKey<FormState>();
  LoginData _ld = new LoginData();
  String inputUsernameHint = "your email";
  String inputUsernameTitle = "Email";
  bool isProgressOffStaged = true;

  updateIdPass(String id, String pass) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
    await prefs.setString('userPassword', pass);
  }

  Future saveUserId(String userUniqueId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userUniqueId', userUniqueId);
  }

  Future<http.Response> loginUser(String id, String pass){
    String getUserLink = DotEnv().env['SERVER_LINK']+'api/getuser/';
    http.post(getUserLink);
    String endPoint = DotEnv().env['SERVER_LINK']+'api/login/';
    return http.post(
      endPoint,
      headers: <String, String>{
        'Content-Type' : 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email' : id,
        'password' : pass
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    Timer(
        Duration(milliseconds: 100), (){
      setState((){
        imageAnim = true;
      });
    }
    );

    Timer(
        Duration(milliseconds: 300), (){
      setState((){
        titleOpacity = 1;
      });
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    double imgWidth = 400;
    Image famImg = Image(
      image: AssetImage('assets/images/family_splash.png'),
      width: imgWidth,
    );
    double screenWidth = MediaQuery.of(context)?.size?.width;
    double screenHeight = MediaQuery.of(context)?.size?.height;

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Stack(
                children:[
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 800),
                    width: imageAnim ? screenWidth/4 : screenWidth - 60,
                    top : imageAnim ? 0 : (screenHeight-imgWidth)/2 ,
                    child: famImg,
                    curve: Curves.easeInOut,
                  ),
                  Positioned(
                    child: AnimatedOpacity(
                      child: Text(
                          MyStrings.appName,
                          style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.primaryAccent ,fontWeight: FontWeight.bold, fontSize: 35)
                      ),
                      duration: Duration(seconds: 1),
                      opacity: titleOpacity,
                    ),
                    top: 15,
                    left: screenWidth/4 ,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: AnimatedOpacity(
                          duration: Duration(seconds: 1),
                          opacity: titleOpacity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: FlatButton(
                                        child: Text(
                                            "Login",
                                            style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.secondaryAccent ,fontWeight: FontWeight.bold, fontSize: 25)
                                        ),
                                        padding: EdgeInsets.all(10),
                                        color: isLoginSelected ? MyColors.primaryAccent : MyColors.primaryColor,
                                        onPressed: ()=>{
                                          setState(() {
                                            isLoginSelected = true;
                                            inputUsernameTitle = "Email";
                                            inputUsernameHint = "your email";
                                          })
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child :SizedBox(
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: FlatButton(
                                        child: Text(
                                            "Register",
                                            style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.secondaryAccent ,fontWeight: FontWeight.bold, fontSize: 25)
                                        ),
                                        padding: EdgeInsets.all(10),
                                        color: isLoginSelected ? MyColors.primaryColor : MyColors.primaryAccent,
                                        onPressed: ()=> {
                                          setState((){
                                            isLoginSelected = false;
                                            inputUsernameHint = "your username";
                                            inputUsernameTitle = "Username";
                                          })
                                        },
                                      ),
                                    ),
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: MyColors.primaryAccent,
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.fromLTRB(15, 30, 15, 15),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: MyColors.secondaryAccent,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty){
                                              return "Please enter the username";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: inputUsernameHint,
                                            labelText: inputUsernameTitle,
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            hintStyle: TextStyle(
                                            ),
                                            contentPadding: EdgeInsets.all(10),
                                          ),
                                          onSaved: (value){
                                            _ld.username = value;
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(15),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: MyColors.secondaryAccent,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: TextFormField(
                                          obscureText: true,
                                          validator: (String value) {
                                            if (value.isEmpty){
                                              return "Please enter the password";
                                            }
                                            if(value.length <6){
                                              return "Password should be at least 6 letters";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "password",
                                            labelText: "Password",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            hintStyle: TextStyle(
                                                fontSize: 15
                                            ),
                                            contentPadding: EdgeInsets.all(10),
                                          ),
                                          onSaved: (value){
                                            _ld.password = value;
                                          },
                                        ),
                                      ),
                                      Container(
                                        child: RaisedButton(
                                          child: Text(
                                            "Submit",
                                            style: Theme.of(context).textTheme.headline3.copyWith(color: MyColors.primaryAccent ,fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          onPressed: (){
                                            FocusScope.of(context).unfocus();
                                            log("Submit Pressed");
                                            if(_formKey.currentState.validate()){
                                              _formKey.currentState.save();
                                              log("Submit -> -- "+_ld.username+" -- "+_ld.password);
                                              updateIdPass(_ld.username, _ld.password);
                                              if(isLoginSelected){
                                                setState(() {
                                                  isProgressOffStaged = false;
                                                });
                                                loginUser(_ld.username, _ld.password).then((value){
                                                  try{
                                                    var rJson = jsonDecode(value.body);
                                                    String id = rJson["_id"];
                                                    saveUserId(id);
                                                    TrackeeInfo.loadTrackeeInfo(id).then((value){
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
                                                    setState(() {
                                                      isProgressOffStaged = true;
                                                    });
                                                  }
                                                });
                                              }
                                              else{
                                                Navigator.pushReplacement(context, PageRouteBuilder(
                                                  pageBuilder: (context, animation1, animation2) => GetDetails(),
                                                  transitionDuration: Duration(milliseconds: 300),
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
                                                ));
                                              }
                                            }
                                          },
                                        ),
                                        margin: EdgeInsets.only(bottom: 20),

                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                      )
                  ),
                ],
              ),
            ) ,
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
            )
          ],
        )
      ),
    );
  }
}


import 'dart:convert';
import 'dart:developer' as d;
import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:famtrack/global/myColors.dart';
import 'package:famtrack/global/myStrings.dart';
import 'package:famtrack/global/trackeeInfo.dart';
import 'package:famtrack/pages/familyCard/familyCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:famtrack/global/myLoc.dart';
import 'package:latlong/latlong.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Home extends StatefulWidget {
  static String id = "login_page";

  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  LatLng currPos = MyLoc.getMyLoc();
  LatLng zoomPos = MyLoc.getMyLoc();
  bool isPosSet = false;
  final MapController controller = new MapController();
  List<Marker> mapMarkers;
  Image famImg;
  int _selectedIndex = 0;
  PageController _pageController;
  bool isOnHomeScreen = true;
  String familyEmail = "";
  bool isErrorOffStaged = true;
  bool isLoadingOn = false;
  String errorMessage = "";
  String myUserId = "";

  void _onItemTapped(int index) {
    if(isOnHomeScreen){
      d.log("print "+index.toString());
      setState(() {
        _selectedIndex = index;
        _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut,
        );
      });
    }
  }

  void onSubmitClicked(){
    setState(() {
      errorMessage = "";
      isErrorOffStaged = true;
      isLoadingOn = true;
    });
   makeConnection().then((value){
     try{
       var retJson = jsonDecode(value.body);
       String success = retJson["msg"];
       if(success != null){
         TrackeeInfo.loadTrackeeInfo(myUserId).then((value){
           setState(() {
             setMarkers();
             isOnHomeScreen = true;
             errorMessage = "";
             isErrorOffStaged = true;
             isLoadingOn = false;
             familyEmail = "";
           });
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
    setState(() {
      errorMessage = "Id might be wrong. Try again";
      isErrorOffStaged = false;
      isLoadingOn = false;
    });
  }

  Future<http.Response> makeConnection() async{
    String getUserLink = DotEnv().env['SERVER_LINK'] + 'api/addtrackee/';
    http.post(getUserLink);
    String endPoint = getUserLink;
    return http.post(
      endPoint,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'Trackee' : [
          {
            'Trackee_id' : familyEmail
          }
        ],
        'Tracker' : [
          {
            'Tracker_id' : myUserId
          }
        ]
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future loadSharedPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUserId = prefs.get('userUniqueId');
  }

  @override
  void initState(){
    super.initState();
    loadSharedPrefs();
    d.log("Home Screen Initiating!!");
    d.log("Trackke Length => "+TrackeeInfo.trackees.length.toString());
    _pageController = new PageController();
    famImg = Image(
      image: AssetImage('assets/images/family_splash.png'),
    );
    setMarkers();
  }

  void setMarkers(){
    mapMarkers = new List<Marker>();
    int i = 0;
    for (TI t in TrackeeInfo.trackees) {
      mapMarkers.add(
          Marker(
              width: 60,
              height: 60,
              point: t.loc,
              builder: (context) => Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      width : 40,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: t.imageAsset,
                        ),
                      ),
                    ),
                    Text(
                      t.name,
                      style: TextStyle(fontSize: 12, fontFamily: 'montserrat', fontWeight: FontWeight.bold),
                    )
                  ],
                ),
//                  child: Text((i++).toString()),
              )
          )
      );
    }
    mapMarkers.add(
        Marker(
            width: 60,
            height: 60,
            point: MyLoc.getMyLoc(),
            builder: (context) => Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width : 40,
                    height: 40,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: MyLoc.getMyImage(),
                      ),
                    ),
                  ),// Your image, has to be replaced
                  Text(
                    "You",
                    style: TextStyle(fontSize: 12, fontFamily: 'montserrat', fontWeight: FontWeight.bold),
                  )
                ],
              ),
//                  child: Text((i++).toString()),
            )
        )
    );
  }

  List<Widget> _widgetlist;

  @override
  Widget build(BuildContext context) {

    _widgetlist = <Widget>[
      Stack(
        children: <Widget>[
          Container(
            child: FlutterMap(
              mapController: controller,
              options: MapOptions(
                center: zoomPos,
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
            alignment: Alignment.centerRight,
            child: Container(
              child: FlatButton(
                child: Icon(
                  Icons.my_location, color:MyColors.primaryAccent,size: 50,
                ),
                color: Colors.transparent,
                onPressed: (){
                  controller.move(MyLoc.getMyLoc(), 13);
                },
              ),
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
          Positioned(
            width: 80,
            bottom: 30,
            left: 10,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: MyColors.primaryAccent,
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                constraints: BoxConstraints(
                  maxHeight: min(400, (40 + (55*TrackeeInfo.trackees.length)) * 1.0),
                ),
                child: CustomScrollView(
                  reverse: true,
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index){
                          return FlatButton(
                            child: Container(
                              width : 50,
                              height: 50,
                              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: TrackeeInfo.trackees[index].imageAsset
                                ),
                              ),
                            ),
                            onPressed: (){
                              controller.move(TrackeeInfo.trackees[index].loc, 13);
                            },
                          );
                        },
                        childCount: TrackeeInfo.trackees.length,
                      ),
                    )
                  ],
                )
            ),
          ),
        ],
      ),
      SizedBox.expand(
        child: DecoratedBox(
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Family Members",
                    style: TextStyle(
                      fontFamily: 'montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  margin: EdgeInsets.all(20),
                ),
              ),
              Flexible(
                flex: 16,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                        return FlatButton(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: MyColors.secondaryAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              margin: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[
                                  Hero(
                                    tag: 'famCard'+index.toString(),
                                    child: Container(
                                      width : 100,
                                      height: 100,
                                      padding: EdgeInsets.all(13),
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: TrackeeInfo.trackees[index].imageAsset,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          TrackeeInfo.trackees[index].name,
                                          style: TextStyle(fontSize: 18, fontFamily: 'montserrat', fontWeight: FontWeight.bold,color: MyColors.primaryColor,),
                                        ),
                                        Text(
                                          TrackeeInfo.trackees[index].isInSafeLocation ? "is in a Safe Locations": "is not in a Safe Locations",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'montserrat',
                                              fontWeight: FontWeight.bold,
                                              color: TrackeeInfo.trackees[index].isInSafeLocation ? Colors.green : Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                          ),
                          onPressed: (){
                            d.log("name => "+TrackeeInfo.trackees[index].name+" Pressed");
                            Navigator.pushNamed(context, FamilyCard.id,
                            arguments: index);
                          },
                        );
                      }, childCount: TrackeeInfo.trackees.length
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          decoration: BoxDecoration(
            color: MyColors.primaryColor,
          ),

        )

      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: MyColors.secondaryAccent,
        elevation: 5.0,
        onPressed: (){
          if(isOnHomeScreen){
            setState(() {
              isOnHomeScreen = false;
            });
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            title: Text(
              "Map",
              style: TextStyle(fontFamily: 'montserrat', fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
              ),
              title: Text(
                "List",
                style: TextStyle(fontFamily: 'montserrat', fontSize: 20, fontWeight: FontWeight.bold),
              ),
            backgroundColor: (_selectedIndex == 1) ? MyColors.primaryAccent : MyColors.secondaryAccent,
          ),
        ],
        backgroundColor: MyColors.primaryAccent,
        selectedItemColor: MyColors.primaryColor,
        unselectedItemColor: MyColors.secondaryAccent,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: <Widget>[
                PageView(
                children: _widgetlist,
                controller: _pageController,
                onPageChanged: (index){
                  setState((){
                    _selectedIndex=index;
                  });
                },
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: isOnHomeScreen ? 0 : 1,
                  duration: Duration(milliseconds: 300),
                  child: Offstage(
                    child: SizedBox(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MyColors.secondaryAccent.withOpacity(0.5),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.all(20),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(color: MyColors.primaryAccent),
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: MyColors.primaryColor,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: MyColors.primaryAccent,),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                        child: Text(
                                          "Enter id of family member",
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: TextField(
                                            style: TextStyle(
                                              fontSize: 17, color: MyColors.primaryAccent,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Enter id here !",
                                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryAccent)),
                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: MyColors.primaryAccent)),
                                              hintStyle: TextStyle(
                                                fontSize: 15, color: MyColors.primaryAccent,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            cursorColor: MyColors.primaryAccent,
                                            keyboardType: TextInputType.emailAddress,
                                            onChanged: (value)=> familyEmail = value,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: MyColors.primaryAccent,),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                        child: Text(
                                          "Or share your unique Id",
                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: MyColors.primaryAccent),
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                        child: RaisedButton(
                                          color: Colors.transparent,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                myUserId,
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MyColors.primaryAccent),
                                              ),
                                              Icon(
                                                Icons.share, size: 30,
                                              )
                                            ],
                                          ),
                                          onPressed: (){
                                            Share.share("Add me to your circle. My user id is : "+myUserId);
                                          },
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: MyColors.primaryAccent),
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: RaisedButton(
                                        color: Colors.transparent,
                                        child: Text(
                                          "Close",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyColors.primaryAccent),
                                        ),
                                        onPressed: (){
                                          setState(() {
                                            isOnHomeScreen = true;
                                            errorMessage = "";
                                            isErrorOffStaged = true;
                                            familyEmail = "";
                                            isLoadingOn = false;
                                          });
                                        },
                                        elevation: 0,
                                      ),
                                    ),
                                    Opacity(
                                      child: CircularProgressIndicator(
                                        backgroundColor: MyColors.secondaryAccent,
                                        valueColor: AlwaysStoppedAnimation<Color>(MyColors.primaryAccent),
                                        strokeWidth: 4,
                                      ),
                                      opacity: isLoadingOn ? 1.0 : 0.0,
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: MyColors.primaryAccent),
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: RaisedButton(
                                        color: Colors.transparent,
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MyColors.primaryAccent),
                                        ),
                                        onPressed: onSubmitClicked,
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                Offstage(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: MyColors.primaryAccent,),
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                      child: Text(
                                        errorMessage,
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  offstage: isErrorOffStaged,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    offstage: isOnHomeScreen,
                  ),
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}
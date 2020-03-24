import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home.dart';
import 'utils/iconMapping.dart';
import 'models/latest_info.dart';

/* Get latest Info */
Future<LatestInfo> getLatestInfo() async {
  final response = await http.get('https://corona.lmao.ninja/all');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return LatestInfo.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load latest info');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<LatestInfo> latestInfo;

  @override
  void initState() {
    super.initState();
    latestInfo = getLatestInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COVID-19 Survey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("COVID-19 Survey"),
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.all(10.0),
            child: FutureBuilder<LatestInfo>(
              future: latestInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    child: ListView(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 190.0,
                          margin: EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/coronavirus-dark.jpg"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/background_overlay.png"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.hands, color: Colors.white, size: 30.0),
                                  title: Text(
                                    'Wash your hands regularly with soap and water, or clean them with alcohol-based hand rub.',
                                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.timesCircle, color: Colors.white, size: 30.0),
                                  title: Text(
                                    'Avoid touching your face.',
                                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(FontAwesomeIcons.home, color: Colors.white, size: 30.0),
                                  title: Text(
                                    'Stay home if you feel unwell.',
                                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ),
                        _infoBox('clipboardCheck', snapshot.data.cases, 'Confirmed cases'),
                        _infoBox('heartbeat', snapshot.data.recovered, 'Cured/Discharged/ Migrated cases'),
                        _infoBox('feather', snapshot.data.deaths, 'Deaths cases'),
                        Container(
                          margin: EdgeInsets.only(top: 10.0),
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(8.0)
                            ),
                            padding: EdgeInsets.all(10.0),
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              )
                            },
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.mapMarked, color: Colors.white, size: 30.0),
                                Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text('Map View', style: TextStyle(fontSize: 20))
                                )
                              ],
                            ),
                          )
                        )
                      ],
                    )
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
                return CircularProgressIndicator();
              },
            ),
          )
        )
      )
    );
  }

  /* _InfoBox */
  Widget _infoBox(String icon, int count, String status) {
    return Container(
      width: double.infinity,
      height: 90.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10.0,
          ),
        ]
      ),
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.only(bottom: 10.0),
      child: Center(
        child: Row(
          children: <Widget>[
            Icon(
              iconMapping[icon],
              color: Colors.redAccent,
              size: 30.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  Text(status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
                ]
              )
            )
          ],
        )
      ),
    ); 
  }

}

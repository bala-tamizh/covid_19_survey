import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'models/covid19.dart';

Future<Covid19List> getAllData() async {
  final response = await http.get('https://corona.lmao.ninja/countries');
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Covid19List.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load latest info');
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();
  Future<Covid19List> allCovidData;
  BitmapDescriptor _sourceIcon;

  @override
  void initState() {
    super.initState();
    allCovidData = getAllData();
    _setSourceIcon();
  }
  double zoomVal = 2.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map View"),
      ),
      body: FutureBuilder<Covid19List> (
        future: allCovidData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data.list;
            for (var i = 0; i < data.length; i++) {
              Marker resultMarker = Marker(
                markerId: MarkerId(data[i].country),
                position: LatLng(data[i].countryInfo.lat.toDouble(), data[i].countryInfo.long.toDouble()),
                onTap: () => {
                  _showCovidDetails(data[i].country, data[i].cases.toString(), data[i].deaths.toString(), data[i].recovered.toString(), data[i].countryInfo.flag)
                },
                icon: _sourceIcon,
              );
              markers.add(resultMarker);
            }

            return Stack(
              children: <Widget>[
                _googleMap(context),
                _zoomMinus(),
                _zoomPlus()
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          // By default, show a loading spinner.
          return Center(
            child: CircularProgressIndicator()
          );
        }
      )
    );
  }

  /* bottomSheet */
  void _showCovidDetails(String country, String cases, String deaths, String recovered, String flag) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ), 
      builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0))),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.network(
                    flag,
                    width: 40,
                    height: 40,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    child: Text(
                      country,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                      ),
                    ),
                  )
                ],
              )
            ),
            _infoValues('Cases', cases),
            Divider(height: 1.0, color: Colors.grey),
             _infoValues('Deaths', deaths),
            Divider(height: 1.0, color: Colors.grey),
            _infoValues('Recovered', recovered),
          ]
        )
      );
    });
  }

  /* infoValues */
  Widget _infoValues(String desc, String count) {
    return Container(
      child: ListTile(
        title: Container(
          margin: EdgeInsets.only(bottom: 5.0),
          child: Text(desc, style: TextStyle(color: Colors.grey, fontSize: 18.0, fontWeight: FontWeight.w400))
        ),
        subtitle: Text(count, style: TextStyle(color: Colors.black, fontSize: 21.0, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /* GoogleMap View */
  Widget _googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 2),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }

  // Zoom Map
  Widget _zoomMinus() {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(FontAwesomeIcons.searchMinus,color:Colors.blue),
        onPressed: () {
          zoomVal--;
          _minus(zoomVal);
        }
      ),
    );
  }

  // Zoom Minus Map
  Widget _zoomPlus() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(FontAwesomeIcons.searchPlus,color:Colors.blue),
        onPressed: () {
          zoomVal++;
          _plus(zoomVal);
        }
      ),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(20.5937, 78.9629), zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(20.5937, 78.9629), zoom: zoomVal)));
  }

  /* map Custom Marker */
  void _setSourceIcon() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/marker.png');
  }

}
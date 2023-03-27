import 'dart:math';

import 'package:brdaokomene/points_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GeoPoint centralGeoPoint = GeoPoint(latitude: 45.40734, longitude: 15.57927, altitude: 300.0);
  final GeoJson geoJson = GeoJson();

  List<GeoJsonPoint> pointsInArea = [];

  @override
  void initState() {
    super.initState();
    _loadPeaks();
  }

  Future<void> _loadPeaks() async {
    var raw = await rootBundle.loadString('assets/peak.geojson');
    GeoJsonFeatureCollection peaks = await featuresFromGeoJson(raw);
    var points = peaks.collection
        .map(
          (e) {
            var point = (e.geometry as GeoJsonPoint);
            point.geoPoint.altitude = double.tryParse(e.properties?["ele"]);
            point.geoPoint.heading = _calculateBearing(centralGeoPoint, point.geoPoint);
            return point;
          },
        )
        .where((element) => element.geoPoint.name != "serie")
        .toList();
    pointsInArea = await geoJson.geofenceDistance(
      point: GeoJsonPoint(geoPoint: centralGeoPoint),
      points: points,
      distance: 10000,
    );
    setState(() {});
  }

  double _calculateBearing(GeoPoint point1, GeoPoint point2) {
    // convert latitude and longitude to radians
    var lat1 = point1.latitude * pi / 180;
    var long1 = point1.longitude * pi / 180;
    var lat2 = point2.latitude * pi / 180;
    var long2 = point2.longitude * pi / 180;

    // calculate the bearing
    var bearing =
        atan2(sin(long2 - long1) * cos(lat2), cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1));

    // convert the bearing to degrees
    bearing = bearing * 180 / pi;

    // make sure the bearing is positive
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/mock_background.jpeg"),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: PointsPainter(pointsInArea),
            ),
          ),
        ],
      ),
    );
  }
}

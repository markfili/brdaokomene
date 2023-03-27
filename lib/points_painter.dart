import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:loggy/loggy.dart';

class PointsPainter extends CustomPainter {
  double maxBearing = 320;
  List<GeoJsonPoint> points;
  Paint pointPaint = Paint()..color = Colors.black;
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
  TextStyle textStyle = const TextStyle(color: Colors.white, fontSize: 15, backgroundColor: Colors.black);
  TextStyle degreeStyle = const TextStyle(color: Colors.white, fontSize: 10, backgroundColor: Colors.black);

  PointsPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (var element in points) {
      logDebug(element.geoPoint.heading);
      logDebug(element.geoPoint.altitude);

      var x = _mapToBearingRange(size.width, element.geoPoint.heading ?? 0);
      var y = size.height - _mapToAltitudeRange(size.height, element.geoPoint.altitude ?? 0);
      var pointOffset = Offset(x, y);

      logDebug("bearing position on screen $x");
      logDebug("altitude position on screen $y");

      textPainter.text = TextSpan(
        text: "${element.geoPoint.name}\n${element.geoPoint.altitude?.toInt()}m\n${element.geoPoint.heading?.toInt()}°",
        style: textStyle,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, pointOffset.translate(-textPainter.width / 2, -80));

      var backgroundTrianglePath = Path();
      backgroundTrianglePath.moveTo(pointOffset.dx, pointOffset.dy + 4);
      backgroundTrianglePath.lineTo(pointOffset.dx + 14, pointOffset.dy - 12);
      backgroundTrianglePath.lineTo(pointOffset.dx - 14, pointOffset.dy - 12);
      backgroundTrianglePath.lineTo(pointOffset.dx, pointOffset.dy + 4);

      canvas.drawPath(backgroundTrianglePath, pointPaint..color = Colors.black);

      var trianglePath = Path();
      trianglePath.moveTo(pointOffset.dx, pointOffset.dy);
      trianglePath.lineTo(pointOffset.dx + 10, pointOffset.dy - 10);
      trianglePath.lineTo(pointOffset.dx - 10, pointOffset.dy - 10);
      trianglePath.lineTo(pointOffset.dx, pointOffset.dy);

      canvas.drawPath(trianglePath, pointPaint..color = Colors.white);
    }
    var step = size.width / maxBearing;
    for (var i = 0; i < maxBearing; i++) {
      if (i % 10 == 0) {
        var x = i * step;
        logDebug(x);
        var isMajorValue = i % 90 == 0;
        var mainLineHeight = (isMajorValue ? 30 : 20);
        var mainLineStrokeWidth = isMajorValue ? 2.0 : 1.0;
        var backgroundLineStrokeWidth = mainLineStrokeWidth + 1.5;
        var backgroundLineHeight = mainLineHeight + 1;
        canvas.drawLine(
            Offset(x, size.height),
            Offset(x, size.height - backgroundLineHeight),
            pointPaint
              ..strokeWidth = backgroundLineStrokeWidth
              ..color = Colors.white,
        );
        canvas.drawLine(
            Offset(x, size.height),
            Offset(x, size.height - mainLineHeight),
            pointPaint
              ..strokeWidth = mainLineStrokeWidth
              ..color = Colors.black,
        );
        if (isMajorValue) {
          textPainter.text = TextSpan(text: "$i°", style: degreeStyle);
          textPainter.layout(minWidth: 0, maxWidth: size.width);
          textPainter.paint(canvas, Offset(x, size.height - 50).translate(-textPainter.width / 2, 0));
        }
      }
    }
  }

  double _mapToBearingRange(double screenWidth, double value) {
    return (screenWidth / maxBearing) * value;
  }

  double _mapToAltitudeRange(double screenHeight, double value) {
    return (screenHeight / 700) * value;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

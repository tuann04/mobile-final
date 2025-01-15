import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/utils/get_user_location.dart';
import 'package:latlong2/latlong.dart';

class TuanScreen extends StatefulWidget {
  const TuanScreen({super.key});

  @override
  _TuanScreenState createState() => _TuanScreenState();
}

class _TuanScreenState extends State<TuanScreen> {
  LatLng? currentLocation;
  Timer? _locationTimer;
  final List<LatLng> trackedPathPoints = [];
  int displayWarning = 0;
  int counter = 0;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    initPosition();
  }

  void initPosition() async {
    final location = await determinePosition();
    if (!mounted) return;

    setState(() {
      currentLocation = LatLng(location.latitude, location.longitude);
      trackedPathPoints.add(currentLocation!);
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  double calculateDistance(LatLng a, LatLng b) {
    return Distance().as(LengthUnit.Meter, a, b);
  }

  void toggleTracking() {
    if (isTracking) {
      _stopLocationUpdates();
    } else {
      startLocationUpdates();
    }
    setState(() {
      isTracking = !isTracking;
    });
  }

  void startLocationUpdates() async {
    _locationTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      final location = await determinePosition();
      final newLocation = LatLng(location.latitude, location.longitude);

      if (!mounted) {
        _locationTimer?.cancel();
        return;
      }

      setState(() {
        currentLocation = newLocation;
        displayWarning = getWarningMessage();
        trackedPathPoints.add(newLocation);
      });
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    setState(() {
      _locationTimer = null;
    });
  }

  int getWarningMessage() {
    if (trackedPathPoints.length < 7) {
      return 0;
    } else {
      double dist = 0;
      for (int i = trackedPathPoints.length - 6;
          i < trackedPathPoints.length - 1;
          i++) {
        dist +=
            calculateDistance(trackedPathPoints[i], trackedPathPoints[i + 1]);
      }
      if (dist < 10) {
        return 1;
      } else if (dist > 20) {
        return 2;
      } else {
        return 0;
      }
    }
  }

  double calculateTotalDistance() {
    double totalDistance = 0;
    for (int i = 0; i < trackedPathPoints.length - 1; i++) {
      totalDistance +=
          calculateDistance(trackedPathPoints[i], trackedPathPoints[i + 1]);
    }
    return totalDistance;
  }

  String _formatElapsedTime() {
    if (_locationTimer == null) return "00:00";
    final duration = _locationTimer!.tick;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text('Running Tracker'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text(
            //     'Your location: $currentLocation, Counter: $counter, Warning: $displayWarning'),
            Expanded(
              child: Stack(
                children: [
                  if (currentLocation == null)
                    Center(child: CircularProgressIndicator())
                  else
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: currentLocation!,
                        initialZoom: 18.0,
                        minZoom: 17.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png',

                          // 'https://tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png',
                          // 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.png',
                          // 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c', 'd'],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: trackedPathPoints,
                              color: Colors.green,
                              strokeWidth: 5,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentLocation!,
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.bolt,
                                color: Colors.yellow[700],
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isTracking)
                    Column(
                      children: [
                        Text(
                          'Tracking...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Time Elapsed: ${_formatElapsedTime()}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Total Distance: ${calculateTotalDistance().toStringAsFixed(2)} meters',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          'Not Tracking',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Press Start to begin tracking your run.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: toggleTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTracking ? Colors.red : Colors.green,
                    ),
                    child: Text(isTracking ? 'Stop' : 'Start'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      if (displayWarning != 0 && isTracking && currentLocation != null)
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color:
                  displayWarning == 1 ? Colors.orangeAccent : Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "You're running too ${displayWarning == 1 ? 'slow' : 'fast'}!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
    ]);
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:health_app/utils/get_user_location.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rive/rive.dart';

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
  bool isTracking = false;
  bool displayCongrats = false;
  DateTime? startTime;
  var riveUrl = 'assets/runner.riv';

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
      stopLocationUpdates();
      setState(() {
        displayCongrats = true;
      });
    } else {
      trackedPathPoints.clear();
      startLocationUpdates();
      setState(() {
        startTime = DateTime.now();
      });
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

  void stopLocationUpdates() {
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
    if (startTime == null)
      return "00:00"; // Return a default value if no start time
    final duration =
        DateTime.now().difference(startTime!); // Calculate the difference
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double calculatePace() {
    final totalDistance = calculateTotalDistance();
    if (startTime == null || totalDistance == 0) return 0;
    final duration = DateTime.now().difference(startTime!);
    if (duration.inSeconds > 0) {
      final pace = duration.inSeconds / totalDistance * 1000;
      return pace / 60;
    } else {
      return 0;
    }
  }

  Future<void> lauchSpotify() async {
    final url = Uri.parse('https://open.spotify.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> shareRunInfo() async {
    final totalDistance = calculateTotalDistance();
    final elapsedTime = _formatElapsedTime();
    final pace = calculatePace();
    final message =
        'I just completed a run! 🏃‍♂️\n\nTotal Distance: ${totalDistance.toStringAsFixed(2)} meters\nTime Elapsed: $elapsedTime\nPace: ${pace.toStringAsFixed(2)} min/km\n\n';
    await Share.share(message);
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
            Expanded(
              child: Stack(
                children: [
                  if (currentLocation == null)
                    Center(
                        child: RiveAnimation.asset(riveUrl, fit: BoxFit.cover))
                  // CircularProgressIndicator())
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
                              color: Colors.black,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isTracking)
                    Column(
                      children: [
                        Text(
                          'Running...',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Time Elapsed: ${_formatElapsedTime()}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
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
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: lauchSpotify,
                          child: Text(
                            '🎵 Play Music on Spotify',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: toggleTracking,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isTracking ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isTracking ? 'Stop' : 'Start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
            margin: EdgeInsets.only(top: 70, left: 20, right: 20),
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
        ),
      if (displayCongrats)
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 Congratulations! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'You completed your run!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  '🏃 Total Distance: ${calculateTotalDistance().toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  '⏱️ Time Elapsed: ${_formatElapsedTime()}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                SizedBox(height: 8),
                Text(
                  '🏃‍♂️ Pace: ${calculatePace().toStringAsFixed(2)} min/km',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: shareRunInfo,
                  icon: Icon(Icons.share),
                  label: Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      displayCongrats = false;
                    });
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ]);
  }
}

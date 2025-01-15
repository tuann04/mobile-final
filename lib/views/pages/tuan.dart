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
  LatLng? _userLocation;
  Timer? _locationTimer;
  final List<LatLng> _trackedPath = [];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() async {
    final location = await determinePosition();
    setState(() {
      _userLocation = LatLng(location.latitude, location.longitude);
      _trackedPath.add(_userLocation!);
    });

    _locationTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      final location = await determinePosition();
      setState(() {
        _userLocation = LatLng(location.latitude, location.longitude);
        _trackedPath.add(_userLocation!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Your location: $_userLocation'),
          Expanded(
            child: Stack(
              children: [
                _userLocation == null
                    ? Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: _userLocation!,
                          initialZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLocation!,
                                width: 80,
                                height: 80,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _trackedPath,
                                color: Colors.blue,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

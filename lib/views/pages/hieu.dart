import 'package:flutter/material.dart';

class HieuScreen extends StatelessWidget {
  const HieuScreen({required Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tro chuyen voi Hieu'),
      ),
      body: Center(
        child: Text('Welcome dasfsd to Hieu Screen'),
      ),
    );
  }
}

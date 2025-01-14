import 'package:flutter/material.dart';
import 'package:health_app/db/database_helper.dart';

class DebugScreen extends StatelessWidget {
  // const DebugScreen({required Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug screen'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              // onPressed: resetSteps
              // delete table
              onPressed: () {
                // widget.viewModel.deleteTable();
                DatabaseHelper.deleteAppDatabase();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Reset database'),
            ),
            ElevatedButton(
              // onPressed: resetSteps
              // delete table
              onPressed: () {
                // log all data
                logger.i("step counter widget All data");
                DatabaseHelper.logAllData();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Log all data'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NguyenScreen extends StatefulWidget {
  const NguyenScreen({Key? key}) : super(key: key);

  @override
  _NguyenScreenState createState() => _NguyenScreenState();
}

class _NguyenScreenState extends State<NguyenScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep and Drink'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Sleep'),
            Tab(text: 'Drink'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Selected time: ${_selectedTime.format(context)}', style: TextStyle(fontSize: 24)),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: Text('Select Time'),
                ),
              ],
            ),
          ),
          Center(
            child: Text('Drink tab content', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

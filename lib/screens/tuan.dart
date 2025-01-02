import 'package:flutter/material.dart';

class TuanScreen extends StatelessWidget {
  const TuanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     elevation: 0, // Remove shadow
      //     title: Text("App chay bo dau hang Viet Nam")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Map Placeholder (replace with actual map later)
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              color: Colors.green,
              // Replace with your actual map image or use a map widget
              image: DecorationImage(
                image: AssetImage('assets/map_placeholder.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Goal Section
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                Text(
                  'YOUR GOAL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circularButton(Icons.remove),
                    const SizedBox(width: 20),
                    const Text(
                      '3 km',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    _circularButton(Icons.add),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      'Distance',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_run, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      'Running',
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ],
            ),
          ),

          // Select Music Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 20),
                const SizedBox(width: 5),
                Text(
                  'Select music',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),

          // Start Button
          Center(
            child: SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Start running logic
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Add some space at the bottom if needed
        ],
      ),
    );
  }

  // Widget _appBarIcon(IconData iconData) {
  //   return Icon(iconData, color: Colors.black, size: 20);
  // }

  Widget _circularButton(IconData iconData) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Icon(iconData, size: 20, color: Colors.black),
    );
  }
}

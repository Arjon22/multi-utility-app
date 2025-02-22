import 'package:flutter/material.dart';
import 'calculator.dart';
import 'calendar.dart';
import 'notes.dart';
import 'recorder.dart';
import 'alarm.dart';
import 'weather.dart';
import 'ui/get_started.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multi-Utility App"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, "Calculator", Icons.calculate, CalculatorScreen(), Colors.blue),
            _buildCard(context, "Calendar", Icons.calendar_today, CalendarScreen(), Colors.orange),
            _buildCard(context, "To-Do List", Icons.note, NotesScreen(), Colors.green),
            _buildCard(context, "Voice Recorder", Icons.mic, RecorderScreen(), Colors.red),
            _buildCard(context, "Alarm", Icons.alarm, AlarmScreen(), Colors.purple),
            _buildCard(context, "Weather", Icons.wb_sunny, GetStarted(), Colors.yellow),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Widget screen, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
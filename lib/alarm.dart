import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  List<Map<String, dynamic>> alarms = [];
  String selectedRingtone = "default_ringtone";
  String? customRingtonePath;
  bool useLabel = false; // Toggle for adding a label
  TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAlarms();
    _loadRingtone();
  }

  void _initializeNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  void _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedAlarms = prefs.getString('alarms');
    if (storedAlarms != null) {
      setState(() {
        alarms = List<Map<String, dynamic>>.from(
            (storedAlarms.isNotEmpty ? List<Map<String, dynamic>>.from([]) : []));
      });
    }
  }

  void _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('alarms', alarms.toString());
  }

  void _loadRingtone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customRingtonePath = prefs.getString("ringtone") ?? "default_ringtone";
    });
  }

  void _selectRingtone() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        customRingtonePath = result.files.single.path!;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("ringtone", customRingtonePath!);
    }
  }

  void _setAlarm(TimeOfDay time) {
    final now = DateTime.now();
    final scheduledTime =
    DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final tz.TZDateTime tzScheduledTime =
    tz.TZDateTime.from(scheduledTime, tz.local);

    final newAlarm = {
      "id": alarms.length + 1,
      "time": time.format(context),
      "label": useLabel ? labelController.text : null, // Optional label
      "ringtone": customRingtonePath ?? "default_ringtone",
    };

    setState(() {
      alarms.add(newAlarm);
    });

    _notificationsPlugin.zonedSchedule(
      (newAlarm["id"] as int), // Cast to integer
      "Alarm",
      useLabel && labelController.text.isNotEmpty
          ? labelController.text
          : "Time to wake up!",
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Notifications',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );


    _saveAlarms();
  }

  void _deleteAlarm(int index) {
    setState(() {
      alarms.removeAt(index);
    });
    _saveAlarms();
  }

  void _showTimePicker() async {
    TimeOfDay? pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null) {
      _setAlarm(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alarm Clock")),
      body: Column(
        children: [
          SwitchListTile(
            title: Text("Set a Label for Alarm"),
            value: useLabel,
            onChanged: (value) {
              setState(() {
                useLabel = value;
              });
            },
          ),
          if (useLabel)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: labelController,
                decoration: InputDecoration(
                  hintText: "Enter alarm label",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ListTile(
            title: Text("Selected Ringtone"),
            subtitle: Text(customRingtonePath ?? "Default Ringtone"),
            trailing: IconButton(
              icon: Icon(Icons.music_note),
              onPressed: _selectRingtone,
            ),
          ),
          ElevatedButton(
            onPressed: _showTimePicker,
            child: Text("Set Alarm"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(alarm["time"]),
                    subtitle: Text(alarm["label"] ?? "No Label"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteAlarm(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

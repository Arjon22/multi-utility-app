import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _reminders = {};
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addReminder() {
    String title = "";
    String category = "Event";
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Reminder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Reminder"),
                onChanged: (value) => title = value,
              ),
              DropdownButtonFormField(
                value: category,
                items: ["Event", "Task", "Birthday"].map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    category = value.toString();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    selectedTime = picked;
                  }
                },
                child: Text("Pick Time"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && selectedTime != null) {
                  setState(() {
                    _reminders[_selectedDate] ??= [];
                    _reminders[_selectedDate]!.add({
                      "title": title,
                      "category": category,
                      "time": selectedTime,
                    });
                    _scheduleNotification(title, _selectedDate, selectedTime!);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _scheduleNotification(String title, DateTime date, TimeOfDay time) async {
    final scheduledDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      "Reminder: $title",
      "It's time for your event!",
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Reminder Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Fix required parameter
      androidAllowWhileIdle: true, // Fix required parameter
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar with Reminders")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            eventLoader: (day) => _reminders[day] ?? [],
          ),
          SizedBox(height: 20),
          Text("Selected"),
          ElevatedButton(
            onPressed: _addReminder,
            child: Text("Add Reminder"),
          ),
          Expanded(
            child: ListView(
              children: (_reminders[_selectedDate] ?? []).map((reminder) {
                return ListTile(
                  leading: Icon(_getCategoryIcon(reminder["category"])),
                  title: Text(reminder["title"]),
                  subtitle: Text("${reminder["category"]} - ${reminder["time"].format(context)}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _reminders[_selectedDate]!.remove(reminder);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Task":
        return Icons.task;
      case "Birthday":
        return Icons.cake;
      default:
        return Icons.event;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  TextEditingController taskController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedNotes = prefs.getString('notes');
    if (storedNotes != null) {
      setState(() {
        notes = List<Map<String, dynamic>>.from(json.decode(storedNotes));
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(notes));
  }

  void addNote(String text) {
    if (text.isNotEmpty) {
      setState(() {
        notes.add({
          'text': text,
          'color': _getRandomColor().value, // Assign random color
        });
      });
      saveNotes();
      taskController.clear();
    }
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void editNote(int index, String newText) {
    setState(() {
      notes[index]['text'] = newText;
    });
    saveNotes();
  }

  Color _getRandomColor() {
    List<Color> colors = [
      Colors.yellow[300]!,
      Colors.green[300]!,
      Colors.blue[300]!,
      Colors.red[300]!,
      Colors.purple[300]!,
    ];
    colors.shuffle();
    return colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To Do List"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: taskController,
              focusNode: _focusNode,
              style: TextStyle(color: Colors.black), // Text is now visible
              decoration: InputDecoration(
                hintText: "Write a note...",
                hintStyle: TextStyle(color: Colors.grey[700]), // Improved hint contrast
                filled: true,
                fillColor: Colors.white, // White background for better contrast
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.black),
                  onPressed: () => addNote(taskController.text),
                ),
              ),
              onSubmitted: (value) => addNote(value), // Save note on Enter key
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(child: Text("No notes yet, start adding!", style: TextStyle(color: Colors.white)))
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onDoubleTap: () {
                    // Edit Note on Double Tap
                    showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController editController =
                        TextEditingController(text: notes[index]['text']);
                        return AlertDialog(
                          title: Text("Edit Note"),
                          content: TextField(
                            controller: editController,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                          ),
                          actions: [
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: Text("Save"),
                              onPressed: () {
                                editNote(index, editController.text);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(notes[index]['color']),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notes[index]['text'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.black),
                            onPressed: () => deleteNote(index),
                          ),
                        ),
                      ],
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

import 'package:flutter/material.dart';
import 'package:myapp/screens/note_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notes = prefs.getStringList('notes');
    if (notes != null) {
      setState(() {
        _notes = notes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: _notes.isEmpty
          ? Center(
              child: Text('No notes found'),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                // Split the note string into title and content
                List<String> noteParts = _notes[index].split('|');
                String title = noteParts[0];
                String content = noteParts[1];
                return ListTile(
                  title: Text(title),
                  subtitle: Text(content),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the note detail screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteDetailScreen()),
          ).then((_) {
            // Reload notes when returning from the detail screen
            _loadNotes();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

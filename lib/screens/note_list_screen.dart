import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_detail_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

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

  Future<bool> _confirmDismiss() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeNote(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notes = prefs.getStringList('notes');
    if (notes != null) {
      notes.removeAt(index);
      await prefs.setStringList('notes', notes);
      setState(() {
        _notes = notes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text('No notes found'),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                // Split the note string into title and content
                List<String> noteParts = _notes[index].split('|');
                String title = noteParts[0];
                String content = noteParts[1];
                return Dismissible(
                  key: Key(_notes[index]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) => _confirmDismiss(),
                  onDismissed: (direction) {
                    _removeNote(index);
                  },
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(content),
                    onTap: () {
                      // Navigate to the note detail screen with note details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(
                            title: title,
                            content: content,
                            onUpdate: () {
                              // Reload notes when returning from detail screen
                              _loadNotes();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the note detail screen to add a new note
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteDetailScreen()),
          ).then((_) {
            // Reload notes when returning from detail screen
            _loadNotes();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NoteDetailScreen extends StatefulWidget {
  final String? title;
  final String? content;
  final Function()? onUpdate;

  const NoteDetailScreen({super.key, this.title, this.content, this.onUpdate});

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _recognizedText = '';
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _contentController = TextEditingController(text: widget.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title != null ? 'Edit Note' : 'Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isRecording ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (_isRecording) {
                        _stopSpeechRecognition();
                      } else {
                        _startSpeechRecognition();
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
                maxLines: null,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveNote,
                child: const Text('Save'),
              ),
              const SizedBox(height: 16.0),
              Text(_recognizedText),
            ],
          ),
        ),
      ),
    );
  }

  void _startSpeechRecognition() async {
    setState(() {
      _isRecording = true;
    });
    if (await _speech.initialize()) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _contentController.text = _recognizedText;
          });
        },
      );
    }
  }

  void _stopSpeechRecognition() {
    setState(() {
      _isRecording = false;
    });
    _speech.stop();
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      String content = _contentController.text;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? notes = prefs.getStringList('notes') ?? [];

      if (widget.title != null) {
        // Editing existing note
        int index = notes.indexOf('${widget.title}|${widget.content}');
        if (index != -1) {
          notes[index] = '$title|$content';
        }
      } else {
        // Adding new note
        notes.add('$title|$content');
      }

      await prefs.setStringList('notes', notes);

      if (widget.onUpdate != null) {
        widget.onUpdate!();
      }

      Navigator.pop(context);
    }
  }
}

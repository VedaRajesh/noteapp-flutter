import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import the database helper

class UpdateNotePage extends StatefulWidget {
  final int noteId; // ID of the note to be updated
  final String initialContent; // Initial content of the note

  const UpdateNotePage({
    Key? key,
    required this.noteId,
    required this.initialContent,
  }) : super(key: key);

  @override
  _UpdateNotePageState createState() => _UpdateNotePageState();
}

class _UpdateNotePageState extends State<UpdateNotePage> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.initialContent); // Initialize with existing note content
  }

  // Function to update note and show feedback
  Future<void> _updateNote() async {
    final content = _contentController.text;

    // Check if the content is empty
    if (content.isEmpty) {
      // Show a SnackBar if the content is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note cannot be empty. Please enter some content.'),
          backgroundColor: Colors.orange, // Orange color for warning
        ),
      );
      return; // Exit the function early
    }

    final dbHelper = DatabaseHelper();

    try {
      await dbHelper.updateNote(widget.noteId, content);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Content updated in database: $content'),
          backgroundColor: Colors.green, // Green color for success
        ),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update content. Please try again.'),
          backgroundColor: Colors.red, // Red color for errors
        ),
      );
      print('Error updating content: $e'); // Print error to console
    }
  }

  @override
  void dispose() {
    _contentController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update your note here",
          style: TextStyle(color: Color(0xFFE2E2B6)), // Light Yellow text
        ),
        backgroundColor: const Color(0xFF03346E), // Dark Blue background
        elevation: 8, // Elevation for 3D effect
        iconTheme: const IconThemeData(color: Color(0xFFE2E2B6)), // Light Yellow arrow
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF03346E), Color(0xFF021526)], // Gradient for AppBar
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5), // Shadow color
                spreadRadius: 2, // Spread of the shadow
                blurRadius: 8, // Blurring effect
                offset: const Offset(0, 4), // Offset for the shadow
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF1A2A43), // Lighter color for the background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF021526), // Dark Blue background for the text field
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        spreadRadius: 1, // Spread of the shadow
                        blurRadius: 5, // Blurring effect
                        offset: const Offset(0, 2), // Offset for the shadow
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Type your updated note here...',
                      hintStyle: TextStyle(color: Color(0xFFE2E2B6)), // Light Yellow hint text
                      border: InputBorder.none, // Remove the default border
                      contentPadding: EdgeInsets.all(16.0), // Padding inside the field
                    ),
                    maxLines: null, // Allow multiple lines
                    style: const TextStyle(
                      color: Color(0xFFE2E2B6), // Light Yellow text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateNote,
        child: const Icon(Icons.save),
        backgroundColor: const Color(0xFF6EACDA), // Light Blue color
        foregroundColor: const Color(0xFF021526), // Dark Blue icon color
      ),
    );
  }
}

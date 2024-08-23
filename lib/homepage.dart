import 'package:flutter/material.dart';
import 'add_content_page.dart'; // Import the new page
import 'update_note_page.dart'; // Import the update note page
import 'database_helper.dart'; // Import the database helper

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild to update search results
  }

  Future<void> _deleteNote(int id) async {
    await DatabaseHelper().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final searchQuery = _searchController.text;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF03346E), Color(0xFF021526)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              children: [
                const Text(
                  "Note App",
                  style: TextStyle(
                    color: Color(0xFFE2E2B6),
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSearching ? MediaQuery.of(context).size.width * 0.5 : 0,
                  child: AnimatedOpacity(
                    opacity: _isSearching ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6EACDA), Color(0xFF4A8BBE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: _isSearching,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: Color(0xFF021526),
                        ),
                        onSubmitted: (query) {
                          setState(() {
                            _isSearching = false;
                            _searchFocusNode.unfocus(); // Dismiss keyboard on submit
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: _isSearching
                    ? Icon(Icons.cancel, color: Color(0xFFE2E2B6))
                    : Icon(Icons.search, color: Color(0xFFE2E2B6)),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _searchFocusNode.unfocus(); // Dismiss keyboard on cancel
                    } else {
                      _isSearching = true;
                      FocusScope.of(context).requestFocus(_searchFocusNode); // Focus search field
                    }
                  });
                },
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: SizedBox(
        height: screenHeight - kToolbarHeight,
        child: Container(
          color: Color(0xFF021526),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: searchQuery.isEmpty
                  ? DatabaseHelper().getNotesStream()
                  : DatabaseHelper().searchNotesStream(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notes found.'));
                } else {
                  final notes = snapshot.data!;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final noteId = note['id'];
                      return GestureDetector(
                        onTap: () async {
                          final updatedContent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateNotePage(
                                noteId: noteId,
                                initialContent: note['content'],
                              ),
                            ),
                          );
                          if (updatedContent != null) {
                            setState(() {
                              note['content'] = updatedContent;
                            });
                          }
                        },
                        child: Dismissible(
                          key: Key(noteId.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteNote(noteId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: Color(0xFF1E2A3A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  note['content'],
                                  style: const TextStyle(
                                    color: Color(0xFFE2E2B6),
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusScope.of(context).unfocus(); // Ensure keyboard is dismissed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContentPage()),
          ).then((_) {
            // No need to refresh notes as StreamBuilder handles updates
          });
        },
        backgroundColor: Color(0xFF6EACDA),
        child: Icon(Icons.add, color: Color(0xFF021526)),
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        splashColor: const Color(0xFF4A8BBE),
        focusColor: const Color(0xFF4A8BBE),
      ),
    );
  }
}

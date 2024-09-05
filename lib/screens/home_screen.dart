import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_db_crud/utils/helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_db_crud/models/note_model.dart';
import 'package:hive_db_crud/screens/note_screen.dart';
import 'package:hive_db_crud/screens/note_update_screen.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:vibration/vibration.dart';

class CrudScreen extends StatefulWidget {
  const CrudScreen({super.key});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  late Box<Note> noteBox;
  final TextEditingController searchController = TextEditingController();
  Set<int> _selectedIndices = {}; // Track selected note indices
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    noteBox = Hive.box<Note>('notes');
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear(); // Clear selection when exiting mode
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelectedNotes() {
    final sortedIndices = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    for (int index in sortedIndices) {
      noteBox.deleteAt(index);
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text('Deleted'),
        description:
            RichText(text: const TextSpan(text: 'Note Deleted Successfully')),
        alignment: Alignment.bottomCenter,
        animationDuration: Duration(milliseconds: 250),
        autoCloseDuration: Duration(seconds: 3),

        icon: const Icon(FluentIcons.delete_dismiss_28_regular),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.blueAccent.withOpacity(0.3),
        backgroundColor: Colors.blueAccent.withOpacity(0.3),
        foregroundColor: Colors.white.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 16,
            offset: Offset(0, 16),
            spreadRadius: 0,
          )
        ],

        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
      );
    }

    // Clear selected indices and exit selection mode
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
    });
  }

  void _handleLongPress(int index) async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(); // Trigger vibration
    }
    if (_isSelectionMode) {
      _toggleSelection(index); // Toggle selection on long press
    } else {
      _toggleSelectionMode(); // Enter selection mode
      _toggleSelection(index); // Select the note
    }
  }

  List<Note> _filterNotes(String query) {
    if (query.isEmpty) {
      return noteBox.values.toList();
    }
    return noteBox.values
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? Row(
                children: [
                  IconButton(
                      onPressed: () {}, icon: Icon(FluentIcons.pin_32_filled))
                ],
              )
            : null,
        title: Text(
          _isSelectionMode
              ? '${_selectedIndices.length} Items Selected'
              : 'Notes',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: _isSelectionMode
            ? [
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _deleteSelectedNotes),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                ),
              ]
            : [],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextFormField(
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
                controller: searchController,
                cursorColor: Colors.white,
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild on search query change
                },
                decoration: InputDecoration(
                  hintText: 'Search Notes',
                  hintStyle: GoogleFonts.nunito(
                    color: const Color.fromRGBO(139, 138, 138, 1),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      FluentIcons.search_32_filled,
                      color: Color.fromRGBO(139, 138, 138, 1),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color.fromRGBO(37, 37, 37, 1),
                  focusColor: Colors.red,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(37, 37, 37, 1),
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(37, 37, 37, 1),
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(37, 37, 37, 1),
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ValueListenableBuilder<Box<Note>>(
                valueListenable: noteBox.listenable(),
                builder: (context, box, _) {
                  final filteredNotes = _filterNotes(searchController.text);
                  return Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        Note note = filteredNotes[index];
                        final isSelected = _selectedIndices
                            .contains(noteBox.keys.toList().indexOf(note.key));

                        return GestureDetector(
                          onLongPress: () => _handleLongPress(
                              noteBox.keys.toList().indexOf(note.key)),
                          onTap: _isSelectionMode
                              ? () => _toggleSelection(
                                  noteBox.keys.toList().indexOf(note.key))
                              : () {
                                  Helper.nextScreen(
                                      context, UpdateScreen(note: note));
                                },
                          child: Stack(
                            children: [
                              GlassContainer.clearGlass(
                                color: Colors.white12,
                                alignment: Alignment.center,
                                blur: 100,
                                borderColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 200, // Ensure minimum width
                                    minHeight: 150, // Ensure minimum height
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blueAccent.withOpacity(
                                            0.3) // Highlight selected note
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18.0),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        note.title,
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        note.content,
                                        style: GoogleFonts.nunito(
                                          color: const Color.fromRGBO(
                                              154, 154, 154, 1),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                      Spacer(),
                                      Text(
                                          DateFormat('hh:mm aaa').format(
                                            note.createdAtDate
                                                .subtract(Duration(days: 1)),
                                          ),
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.nunito(
                                            color: const Color.fromRGBO(
                                                154, 154, 154, 1),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              if (_isSelectionMode)
                                Positioned(
                                  right: 15.0,
                                  bottom: 5,
                                  top: 90,
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: Colors.white,
                                    size: 24.0, // Adjust size if needed
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Helper.nextScreen(context, NoteScreen());
        },
        child: const Icon(
          FluentIcons.add_48_regular,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueAccent
            .withOpacity(0.9), // Customize the background color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(50.0), // Ensure the button is round
        ),
        elevation: 8.0, // Customize the shadow elevation if needed
      ),
    );
  }
}

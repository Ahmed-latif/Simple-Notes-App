import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_db_crud/models/note_model.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late Box<Note> noteBox;

  @override
  void initState() {
    noteBox = Hive.box<Note>('notes');
    // TODO: implement initState
    super.initState();
  }

  final TextEditingController titleController = TextEditingController();

  final UndoHistoryController undoHistoryController = UndoHistoryController();
  final TextEditingController contentController = TextEditingController();
  var outputFormat = DateFormat('MMMM dd hh:mm aaa');

  @override
  Widget build(BuildContext context) {
    var dateTime = outputFormat.format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          ValueListenableBuilder<UndoHistoryValue>(
            valueListenable: undoHistoryController,
            builder:
                (BuildContext context, UndoHistoryValue value, Widget? child) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      undoHistoryController.undo();
                    },
                    icon: Icon(
                      FluentIcons.arrow_reply_32_regular,
                      color: value.canUndo ? Colors.white : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      undoHistoryController.redo();
                    },
                    icon: Icon(
                      FluentIcons.arrow_forward_32_regular,
                      color: value.canRedo ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
              onPressed: () {
                final newNote = Note(
                    createdAtTime: DateTime.now(),
                    createdAtDate: DateTime.now(),
                    title: titleController.text,
                    content: contentController.text);
                noteBox.add(newNote);

                Navigator.pop(context);
              },
              icon: Icon(
                FluentIcons.checkmark_32_filled,
                color: Colors.white,
              ))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
                cursorHeight: 35,
                cursorColor: Color.fromRGBO(154, 154, 154, 1),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: InputBorder.none,
                  label: Text(
                    'Title',
                    style: GoogleFonts.nunito(
                        color: Color.fromRGBO(154, 154, 154, 70),
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  ),

                  // border: InputBorder.none,
                ),
                controller: titleController,
              ),
              Text(
                dateTime,
                textAlign: TextAlign.start,
                style: GoogleFonts.nunito(
                    color: Color.fromRGBO(154, 154, 154, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: TextFormField(
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400),
                  cursorHeight: 35,
                  cursorColor: Color.fromRGBO(154, 154, 154, 1),
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    // border: InputBorder.none,
                    label: Text(
                      'Start Typing..',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.nunito(
                          color: Color.fromRGBO(154, 154, 154, 70),
                          fontSize: 25,
                          fontWeight: FontWeight.w500),
                    ),
                    alignLabelWithHint: true,

                    border: InputBorder.none,
                  ),
                  controller: contentController,
                  undoController: undoHistoryController,
                  textAlign: TextAlign.start,
                  maxLength: 10000,
                  maxLines: MediaQuery.sizeOf(context).height.toInt(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

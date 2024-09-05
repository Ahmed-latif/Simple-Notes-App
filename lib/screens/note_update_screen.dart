import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_db_crud/models/note_model.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart'; // Import your Note model and Hive or relevant packages

class UpdateScreen extends StatefulWidget {
  final Note note;

  UpdateScreen({required this.note});

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    // Create a new note with updated data
    final updatedNote = Note(
      createdAtTime: DateTime.now(),
      createdAtDate: DateTime.now(),
      title: _titleController.text,
      content: _contentController.text,
    );

    // Save the updated note back to the box
    final box = Hive.box<Note>('notes');
    final index = box.values.toList().indexOf(widget.note);
    if (index != -1) {
      box.putAt(index, updatedNote);
    }

    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    var outputFormat = DateFormat('MMMM dd hh:mm aaa');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Share.share(_titleController.text,
                    subject: _contentController.text);
              },
              icon: Icon(FluentIcons.share_48_regular)),
          IconButton(
              onPressed: () {},
              icon:
                  Icon(FluentIcons.arrow_reply_32_filled, color: Colors.white)),
          IconButton(
              onPressed: () {},
              icon: Icon(
                FluentIcons.arrow_forward_32_filled,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                _updateNote();
              },
              icon: Icon(
                FluentIcons.checkmark_32_filled,
                color: Colors.white,
              ))
        ],
        titleSpacing: -5,
        title: Text(
          'Edit Note',
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
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
                  floatingLabelBehavior: FloatingLabelBehavior.always,

                  border: InputBorder.none,

                  label: Text(
                    'Title',
                    style: GoogleFonts.nunito(
                        color: Color.fromRGBO(154, 154, 154, 1),
                        fontSize: 25,
                        fontWeight: FontWeight.w400),
                  ),

                  // border: InputBorder.none,
                ),
                controller: _titleController,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                outputFormat.format(widget.note.createdAtDate),
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
                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    // border: InputBorder.none,
                    label: Text(
                      'Description',
                      textAlign: TextAlign.start,
                      style: GoogleFonts.nunito(
                          color: Color.fromRGBO(154, 154, 154, 1),
                          fontSize: 25,
                          fontWeight: FontWeight.w400),
                    ),
                    alignLabelWithHint: true,

                    border: InputBorder.none,
                  ),
                  controller: _contentController,
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

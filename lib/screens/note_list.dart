import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notes_app/Doodle/draw.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:notes_app/global.dart' as g;
import 'package:notes_app/audio/audio_start.dart';
class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    print("menu");
    print(g.scheduledTime);
    if (noteList == null) {
      noteList = [];
      updateListView();
    }

    Widget myAppBar() {
      return AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headline5),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: noteList.length == 0
            ? Container()
            : IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () async {
            final Note result = await showSearch(
                context: context, delegate: NotesSearch(notes: noteList));
            if (result != null) {
              navigateToDetail(result, 'Edit Note');
            }
          },
        ),
        actions: <Widget>[
          noteList.length == 0
              ? Container()
              : IconButton(
            icon: Icon(
              axisCount == 2 ? Icons.list : Icons.grid_on,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                axisCount = axisCount == 2 ? 4 : 2;
              });
            },
          )
        ],
      );
    }

    return Scaffold(
      appBar: myAppBar(),
      body: noteList.length == 0
          ? Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Click on the add button to add a new note!',
                style: Theme.of(context).textTheme.bodyText2),
          ),
        ),
      )
          : Container(
        color: Colors.white,
        child: getNotesList(),
      ),
      floatingActionButton: SpeedDial(
        //marginBottom: 10, //margin bottom
        //icon: Icons.menu, //icon on Floating action button
        //activeIcon: Icons.close, //icon when menu is expanded on button
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 28.0),
        backgroundColor: Colors.deepOrangeAccent, //background color of button
        foregroundColor: Colors.white, //font color, icon color in button
        activeBackgroundColor: Colors.deepPurpleAccent, //background color when menu is expanded
        activeForegroundColor: Colors.white,
        buttonSize: 56.0, //button size
        visible: true,
        //closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'), // action when menu opens
        onClose: () => print('DIAL CLOSED'), //action when menu closes
        elevation: 8.0, //shadow elevation of button
        shape: CircleBorder(), //shape of button

        children: [
          SpeedDialChild( //speed dial child
              child: Icon(Icons.notes),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              label: 'Add Note',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {navigateToDetail(Note('', '', 3, 0), 'Add Note');
              }
            //onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
              child: Icon(Icons.brush),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              label: 'Add Doodle',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyApp1()));
              }
            //onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            label: 'Add Audio Note',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () 
            {Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyApp3()));
              }
            //onLongPress: () => print('THIRD CHILD LONG PRESS'),
          ),
          //add more menu item children here
        ],
      ),


    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(this.noteList[index], 'Edit Note');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: colors[this.noteList[index].color],
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          this.noteList[index].title,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ),
                    Text(
                      getPriorityText(this.noteList[index].priority),
                      style: TextStyle(
                          color:
                          getPriorityColor(this.noteList[index].priority)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            this.noteList[index].description == null
                                ? ''
                                : this.noteList[index].description,
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(this.noteList[index].date,
                          style: Theme.of(context).textTheme.subtitle2),
                    ])
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
        break;
      case 2:
        return '!!';
        break;
      case 3:
        return '!';
        break;

      default:
        return '!';
    }
  }

  // void _delete(BuildContext context, Note note) async {
  //   int result = await databaseHelper.deleteNote(note.id);
  //   if (result != 0) {
  //     _showSnackBar(context, 'Note Deleted Successfully');
  //     updateListView();
  //   }
  // }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}

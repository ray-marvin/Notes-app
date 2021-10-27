import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:notes_app/global.dart' as g;

var stime;

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  FlutterLocalNotificationsPlugin fltrNotification;

  @override
  void initState() {
    super.initState();
    var androidInitilize = new AndroidInitializationSettings('icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings =
        new InitializationSettings(androidInitilize, iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
  }

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int color;
  bool isEdited = false;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;
    color = note.color;

    final format = DateFormat("yyyy-MM-dd HH:mm");

    return WillPopScope(
      onWillPop: () async {
        isEdited ? showDiscardDialog(context) : moveToLastScreen();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            appBarTitle,
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: colors[color],
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                isEdited ? showDiscardDialog(context) : moveToLastScreen();
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.save,
                color: Colors.black,
              ),
              onPressed: () {
                titleController.text.length == 0
                    ? showEmptyTitleDialog(context)
                    : _save();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.black),
              onPressed: () {
                showDeleteDialog(context);
              },
            )
          ],
        ),
        body: Container(
          color: colors[color],
          child: Column(
            children: <Widget>[
              PriorityPicker(
                selectedIndex: 3 - note.priority,
                onTap: (index) {
                  isEdited = true;
                  note.priority = 3 - index;
                },
              ),
              ColorPicker(
                selectedIndex: note.color,
                onTap: (index) {
                  setState(() {
                    color = index;
                  });
                  isEdited = true;
                  note.color = index;
                },
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: titleController,
                  maxLength: 255,
                  style: Theme.of(context).textTheme.bodyText2,
                  onChanged: (value) {
                    updateTitle();
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Title',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    maxLength: 255,
                    controller: descriptionController,
                    style: Theme.of(context).textTheme.bodyText1,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'Description',
                    ),
                  ),
                ),
              ),
              Column(children: <Widget>[
                Text('Remind Me on (${format.pattern})'),
                DateTimeField(
                  format: format,
                  onShowPicker: (context, currentValue) async {
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      stime = DateTimeField.combine(date, time);
                      currentValue = stime;
                      print("stime");
                      print(stime);
                      if (stime != null) {
                        g.scheduledTime = stime;
                      }
                      return DateTimeField.combine(date, time);
                    } else {
                      print("stime is null");
                      return g.scheduledTime;
                    }
                  },
                ), 
              ]),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: RaisedButton(
                    onPressed: _showNotification, child: Text("Set Reminder")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer", "This is my channel",
        importance: Importance.Max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(androidDetails, iSODetails);

    // await fltrNotification.show(
    //     0, "Task", "You created a Task",
    //     generalNotificationDetails, payload: "Task");

    //var scheduledTime = DateTime.now().add(Duration(seconds : 5));

    //print(DateTime.now().add(Duration(seconds : 10)));
    print("in notif widget");
    print(g.scheduledTime);
    fltrNotification.schedule(
        1, "Reminder", note.title, stime, generalNotificationDetails);
        //
  }

  Future notificationSelected(String payload) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text("Note"),
      ),
    );
  }

  void showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Discard Changes?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to discard changes?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                moveToLastScreen();
              },
            ),
          ],
        );
      },
    );
  }

  void showEmptyTitleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Title is empty!",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text('The title of the note cannot be empty.',
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("Okay",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete Note?",
            style: Theme.of(context).textTheme.bodyText2,
          ),
          content: Text("Are you sure you want to delete this note?",
              style: Theme.of(context).textTheme.bodyText1),
          actions: <Widget>[
            TextButton(
              child: Text("No",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(color: Colors.purple)),
              onPressed: () {
                Navigator.of(context).pop();
                _delete();
              },
            ),
          ],
        );
      },
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    isEdited = true;
    note.title = titleController.text;
  }

  void updateDescription() {
    isEdited = true;
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    if (note.id != null) {
      await helper.updateNote(note);
    } else {
      await helper.insertNote(note);
    }
  }

  void _delete() async {
    await helper.deleteNote(note.id);
    moveToLastScreen();
  }
}

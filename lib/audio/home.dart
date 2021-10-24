import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'list.dart';
import 'view.dart';

class HomePage extends StatefulWidget {
  final String _appTitle;

  const HomePage({Key key, String title})
      : assert(title != null),
        _appTitle = title,
        super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory  appDir;
  List<String> records;

  @override
  void initState() {
    super.initState();
    records = [];
    getExternalStorageDirectory().then((value) {
      appDir = value;
      Directory appDirec = Directory("${appDir.path}/Audiorecords/");
      appDir = appDirec;
      appDir.list().listen((onData) {
        records.add(onData.path);
      }).onDone(() {
        records = records.reversed.toList();
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    appDir = null;
    records = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child:  InkWell(child: Icon(Icons.mic),onTap: (){

          show(context);},),
      ),
      appBar: AppBar(
        title: Text('Audio Notes', style: Theme.of(context).textTheme.headline5),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple[300],
       
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Records(
              records: records,
            ),
          ),

        ],
      ),
    );
  }

  _onFinish() {
    records.clear();
    print(records.length.toString());
    appDir.list().listen((onData) {
      records.add(onData.path);
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      setState(() {});
    });
  }

  void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white70,
          child: Recorder(
            save: _onFinish,
          ),
        );
      },
    );
  }

}
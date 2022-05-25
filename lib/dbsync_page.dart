import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';

import 'cubit/cubit.dart';
import 'main.dart';
import 'utils/utils.dart';

class DBSyncPage extends StatefulWidget {
  const DBSyncPage({Key? key}) : super(key: key);

  @override
  _DBSyncPageState createState() => _DBSyncPageState();
}

class _DBSyncPageState extends State<DBSyncPage> {
  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;
  final _text = TextEditingController();
  var data = [];
  // homepage layout
  bool? _connectionStatus;
  // final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // void initState() {
  //   _getAllData();
  // }
  @override
  void initState() {
    _getAllData();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _insert() async {
    // row to insert
    // Map<String, dynamic> row = {
    //   DatabaseHelper.columnName : 'Bob',
    //   DatabaseHelper.columnAge  : 23
    // };
    // final id = await dbHelper.insert(row);
    // print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('query all rows:');
    allRows?.forEach((row) => debugPrint(row.toString()));
  }

  Future<dynamic> _getunsynchedrecords() async {
    final allRows = await dbHelper.queryUnsynchedRecords();
    debugPrint('query all unsynched:');
    allRows?.forEach((row) => debugPrint(row.toString()));
    return allRows;
  }

  Future<dynamic> queryAllRecords() async {
    final allData = await dbHelper.queryAllRecords();
    debugPrint('query all unsynched:');
    return allData;
  }

  void _update(id, name) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.status: 1
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id!);
    debugPrint('deleted $rowsDeleted row(s): row $id');

    setState(() {
      _getAllData();
    });
  }

  void _syncitnow(_connectionStatus) async {
    // final nameProvider = Provider.of<SendNameProvider>(context, listen: false);
    // if (_connectionStatus == true) {
    //   var allRows = await _getunsynchedrecords();
    //   allRows.forEach((row) async {
    //     await nameProvider.sync(row['name'], _connectionStatus);
    //     _update(row['id'], row['name']);
    //   });
    // }
    // await context.read<SendNameCubit>().sync('bowo', _connectionStatus);
    if (_connectionStatus == true) {
      var allRows = await _getunsynchedrecords();
      allRows.forEach((row) async {
        await context
            .read<SendNameCubit>()
            .sync(row['name'], _connectionStatus);
        _update(row['id'], row['name']);
        setState(() {
          _getAllData();
        });
      });
    }
  }

  void _getAllData() async {
    data.clear();
    var allRows = await queryAllRecords();
    allRows.forEach((row) async {
      data.add(row);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final nameProvider = Provider.of<SendNameProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text("SQLite"),
        ),
        body: BlocListener<SendNameCubit, SendNameState>(
          listener: (context, state) {
            if (state is SendNameSuccess) {
              Flushbar(
                duration: const Duration(seconds: 4),
                flushbarPosition: FlushbarPosition.TOP,
                backgroundColor: const Color(0xFF503E9D),
                message: state.successResponse?.message,
              ).show(context);

              // debugPrint('Seharusnya refresh1');
            } else if (state is SendNameFailed) {
              Flushbar(
                duration: const Duration(seconds: 5),
                flushbarPosition: FlushbarPosition.TOP,
                backgroundColor: const Color(0xffFF5C83),
                message: state.errorMessage,
              ).show(context);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                OfflineBuilder(
                  connectivityBuilder: (
                    BuildContext context,
                    ConnectivityResult connectivity,
                    Widget child,
                  ) {
                    debugPrint('status : $connectivity');
                    _connectionStatus = connectivity != ConnectivityResult.none;
                    if (connectivity != ConnectivityResult.none) {
                      _syncitnow(_connectionStatus);
                    }
                    return Stack(children: [child]);
                  },
                  builder: (BuildContext context) {
                    return const SizedBox();
                  },
                ),
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        child: const Text(
                          'delete',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          _delete();
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: TextField(
                                  controller: _text,
                                  decoration: const InputDecoration(
                                      hintText: 'Enter the Value',
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(left: 10)),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await context
                                    .read<SendNameCubit>()
                                    .addName(_text.text, _connectionStatus);
                                _getAllData();
                                // setState(() {
                                //   nameProvider
                                //       .addName(_text.text, _connectionStatus)
                                //       .then((value) {
                                //     _text.clear();
                                //     _getAllData();
                                //   });
                                // });
                              },
                              child: const Text('Submit'),
                              // textColor: Colors.white,
                              // color: Colors.blueAccent,
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        child: const Text(
                          'query',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          _query();
                        },
                      ),
                      ElevatedButton(
                        child: const Text(
                          'Query Unsync',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          _getunsynchedrecords();
                        },
                      ),
                      // FutureBuilder(
                      //     future: _getAllData(),
                      //     builder:
                      //         (BuildContext context, AsyncSnapshot snapshot) {
                      //       data = snapshot.data;
                      //       if (snapshot.hasData) {
                      //         return ListView.builder(
                      //             itemCount: data.length,
                      //             itemBuilder: (context, i) {
                      //               return ListTile(
                      //                 title: Text(data[i]['name']),
                      //                 trailing: data[i]['status'] != 0
                      //                     ? const Icon(Icons.check)
                      //                     : const Icon(Icons.clear),
                      //               );
                      //             });
                      //       } else if (snapshot.hasError) {
                      //         return Text('${snapshot.error}');
                      //       }
                      //     })
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          return ListTile(
                            onTap: () {
                              logger.d('sedang di tekan', data);
                            },
                            title: Text(data[i]['name']),
                            trailing: data[i]['status'] != 0
                                ? const Icon(Icons.check)
                                : const Icon(Icons.clear),
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  // Button onPressed methods

}

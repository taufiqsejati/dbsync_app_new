import 'dart:async';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:dbsync_app_new/cubit/send_name_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'providers/send_name_provider.dart';
import 'utils/database_helper.dart';
import 'utils/utils.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
    noBoxingByDefault: false,
  ),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApiConfig();
  BlocOverrides.runZoned(
    () => runApp(const MyApp()),
    blocObserver: MyAppObserver(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SendNameCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        home: const MyHome(),
      ),
    );
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //       create: (_) => SendNameProvider(),
    //     ),
    //   ],
    // child: const MaterialApp(
    //   home: MyHome(),
    // ),
    // );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
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

  _syncitnow(_connectionStatus) async {
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
      });
    }
  }

  Future _getAllData() async {
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
                    debugPrint('status 1 : ${connectivity}');
                    _connectionStatus = connectivity != ConnectivityResult.none;
                    if (connectivity != ConnectivityResult.none) {
                      debugPrint('status 2 : ');
                      _syncitnow(_connectionStatus);
                    }
                    debugPrint('status 3 : ');
                    return Stack(children: [child]);
                  },
                  builder: (BuildContext context) {
                    return const SizedBox();
                  },
                ),
                SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: MediaQuery.of(context).size.width * 1,
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
                        SizedBox(
                            height: 400.0,
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  title: Text(data[i]['name']),
                                  trailing: data[i]['status'] != 0
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.clear),
                                );
                              },
                            ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  // Button onPressed methods

}

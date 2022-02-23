import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.red),
      home: DomControl(),
    );
  }
}

class DomControl extends StatefulWidget {
  const DomControl({Key? key}) : super(key: key);

  @override
  _DomControlState createState() => _DomControlState();
}

class _DomControlState extends State<DomControl> {
  String _fetchedData = "";
  dynamic _fetchedHTML = null;
  TextEditingController _urlEditingController =
      TextEditingController(text: "https://yahoo.co.jp");
  TextEditingController _queryEditingController = TextEditingController();
  List<dynamic> _matched = [];
  ScrollController _scrollController = ScrollController();
  final _copyedSnackbar = SnackBar(
    content: const Text('Copyed!'),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );

  void fetchData() {
    setState(() {
      _matched = [];
    });
    if (_urlEditingController.text == "") return;
    http.get(Uri.parse(_urlEditingController.text)).then((value) {
      String body = value.body.toString();
      setState(() {
        _fetchedData = body;
      });
    });
  }

  void queryData() {
    print('queryData');
    if (_queryEditingController.text == "") return;
    print('running');
    dynamic document = parse(_fetchedData);
    final result =
        document.querySelectorAll("p").map((item) => item.text).toList();
    setState(() {
      _matched = result;
    });
  }

  void scrollToTop() {
    _scrollController.jumpTo(_scrollController.position.minScrollExtent);
  }

  void scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _urlEditingController.dispose();
    _queryEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('DomControl'),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20.0, right: 16.0, left: 16.0, bottom: 10.0),
            child: Container(
              child: Column(
                children: [
                  Text('URL'),
                  Row(
                    children: [
                      Flexible(
                          child: TextField(
                        controller: _urlEditingController,
                      )),
                      ElevatedButton(onPressed: fetchData, child: Text('取得'))
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          child: TextField(
                        controller: _queryEditingController,
                      )),
                      ElevatedButton(onPressed: queryData, child: Text('絞り込み'))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Expanded(
                            child: _matched.length >= 1
                                ? Column(
                                    children: List.generate(
                                        _matched.length,
                                        (index) => Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CopyAbleText(index, context),
                                                  Divider(),
                                                ],
                                              ),
                                            )),
                                  )
                                : Text(_fetchedData))),
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              onPressed: scrollToTop,
              child: Icon(Icons.arrow_drop_up),
            ),
            SizedBox(
              height: 5,
            ),
            FloatingActionButton(
              onPressed: scrollToBottom,
              child: Icon(Icons.arrow_drop_down),
            ),
          ],
        ));
  }

  GestureDetector CopyAbleText(int index, BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print('copy');
        Clipboard.setData(ClipboardData(text: _matched[index]));
        ScaffoldMessenger.of(context).showSnackBar(_copyedSnackbar);
      },
      child: Text(
        _matched[index].toString(),
        textAlign: TextAlign.left,
      ),
    );
  }
}

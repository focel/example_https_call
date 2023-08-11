import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      home: ExamplePage(catId: '40'),
    );
  }
}

class ExamplePage extends StatefulWidget {
  String catId;

  ExamplePage({required this.catId});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String responseData = 'work or not';
  String responseFailed = 'failed';
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    //  final url = Uri.parse('https://youinroll.com/lib/ajax/getCategory.php');
    /*final response = await http.get(
      url,
      headers: {'cat_id': widget.catId},
    );*/
    // final   response = http.get('https://jsonplaceholder.typicode.com/posts/1') ;
    Uri url = Uri.parse('https://youinroll.com/lib/ajax/getCategory.php?cat_id=${widget.catId}');
    var response = await get(url);

    if (response.statusCode == 200) {
      setState(() {
        responseData = response.body;
        print('Request obtained with status: $responseData.');

      });
    } else {
      responseFailed = response.statusCode as String;


      print('Request failed with status: ${response.statusCode}.');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example Page')),
      body: Center(
          child: Column(
              children:[
                Text('Hello world\n\n'),
                Text(widget.catId),
                Text(responseData),
                Text(responseFailed),
              ])
      ),
    );
  }
}
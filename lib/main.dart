import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';

import 'package:example_https_call/api.dart';


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
  late bool isCatExist;

  String responseData = 'not work';
  String responseFailed = 'failed';
  String catName = '...';
  String catPictureLink = '...';
  String catAllFollowers = '...';
  String catAllViews = '...';
  bool isCategoryInfoLoaded = false;

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
    var response1 = await get(url);
    Response response = await get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var check = jsonResponse['result'] as bool;
      isCatExist = check;
      if (!check) {

        print('404 error');

      } else {
        var catInfo = jsonResponse['category'];
        catName = catInfo['cat_name'];
        catPictureLink = catInfo['picture'];
        catAllFollowers = catInfo['all_followers'];
        catAllViews = catInfo['all_views_cat'];
        setState(() {
         // catPictureLink = catInfo['picture'];
//////////////////
          isCategoryInfoLoaded = true;
          responseData = response.body;
         // print('probando si funciona: $catPictureLink.');
          var jsonResponse = jsonDecode(response.body);
          var userData = jsonResponse['response'];
          var myUserAvatar = userData["avatar"].toString();
          print('respuesta: $jsonResponse');
///////////////////
        });
      }

      setState(() {
        responseData = response.body;
        print('Request obtained with status: $responseData.');
        var jsonResponse = jsonDecode(response.body);
        var userData = jsonResponse['response'];
        var myUserAvatar = userData["avatar"].toString();
///////////////////////////////////////////
        print('respuesta: $jsonResponse');


///////////////////////////////////////
      });
    } else {
      responseFailed = response.statusCode as String;
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCategoryInfoLoaded = false;
    String catPictureLink = 'https://storage1.youinroll.com/storage/uploads/d6876bbe9c428316bee2e261ace301a9-1.jpg';
    return Scaffold(
      appBar: AppBar(title: Text('Example Page')),
      body: Center(
          child: Column(
              children:[
                Text('Hello world\n\n'),

                Text(catPictureLink),

                Text('\n\n'),
                Text(widget.catId),
                Text(responseData),
                Text(responseFailed),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.white54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 0.75),
                      ),
                    ],
                  ),
                  width: 150,
                  height: 150,
                  child: !isCategoryInfoLoaded
                      ? Image.network('$catPictureLink',
                      )
                      : Image.network('${Api.httpsDomain}$catPictureLink',
                      width: 100, fit: BoxFit.fitHeight),
                ),


              ])
      ),
    );
  }
}
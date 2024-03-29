import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> dogImages = new List();
  ScrollController _scrollController = new ScrollController();
  var xTop = 0.0;
  var xBottom = 0.0;
  var fetchSuccess = true;

  @override
  void initState() {
    super.initState();

    if (xBottom == 0.0) {
      fetch();
    }

    _scrollController.addListener(() {
      if (xTop == 0.0 && xBottom == 0.0) {
        xTop = xBottom;
        xBottom = 4000;
      }

      if (_scrollController.position.pixels >= xTop &&
          _scrollController.position.pixels <= xBottom) {
        if (fetchSuccess) {
          fetchSuccess = false;
          fetch();
        }
      } else {
        fetchSuccess = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: dogImages.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 5.0),
            child: Image.network(dogImages[index], fit: BoxFit.fitWidth),
          );
        },
      ),
    );
  }

  fetch() async {
    final response = await http.get(
        "https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=cat&per_page=20&api_key=e4774ca74391030bec9bfac5e014f5d7&format=json&nojsoncallback=1");

    if (response.statusCode == 200) {
      setState(() {
        var photos = json.decode(response.body)['photos']['photo'];
        for (var photo in photos) {
          dogImages.add(
              "https://farm${photo['farm']}.staticflickr.com/${photo['server']}/${photo['id']}_${photo['secret']}_m.jpg");
        }
      });

      xTop = xBottom;
      xBottom += 4500;
    } else {
      throw Exception("Failed to load images!");
    }
  }
}

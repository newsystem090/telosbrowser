import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  List<String> peers = [
    "https://telos.caleos.io",
    "https://mainnet.telos.goodblock.io",
    "https://node1.us-west.telosglobal.io",
    "https://node1.us-east.telosglobal.io",
    "https://telos.greymass.com",
    "https://telos-mainnet.infinitybloc.io",
    "https://telos.teleology.one",
    "https://api.telos.kitchen",
    "https://api.telos.telosgreen.com",
    "https://api.telosmadrid.io",
    "https://telos.eosrio.io",
    "https://api.telosuk.io",
    "https://mainnet.persiantelos.com",
    "https://api.telos.africa",
    "https://api.theteloscope.io",
    "https://api.telosarabia.net",
    "https://api.telos.eostribe.io",
    "https://mainnet.telosusa.io",
    "https://telos.eosargentina.io",
    "https://telosgermany.genereos.io",
    "https://telos.eu.eosamsterdam.net",
    "https://telos.api.boid.animus.is",
    "https://tlos-api.katalyo.com",
    "https://p2p.creativblock.org",
    "https://telosapi.sentnl.io",
    "https://api.dailytelos.net",
    "https://telos.eosvenezuela.io",
    "https://api.teloskorea.com",
    "https://telos.pandabloks.com",
    "https://telos.cryptolions.io",
    "https://telos.eossweden.eu",
    "https://api.telos.cryptobloks.io",
    "https://telosapi.actifit.io",
  ];

  final _formKey = GlobalKey<FormState>();
  TextEditingController tce = TextEditingController();
  String htmlData = "";
  String htmlErrorData = "<html><div>network issue</div></html>";

  void performRedundancyNetworkRequests() async {

    var random = Random();

    int randomPeer1 = random.nextInt(32);

    int randomPeer2 = random.nextInt(32);
    while(randomPeer2 == randomPeer1){
      randomPeer2 = random.nextInt(32);
    }
    int randomPeer3 = random.nextInt(32);
    while(randomPeer3 == randomPeer1 ||
    randomPeer3 == randomPeer2){
      randomPeer3 = random.nextInt(32);
    }

    List<String> responses = await Future.wait([
      performNetworkRequest(peers[randomPeer1]),
      performNetworkRequest(peers[randomPeer2]),
      performNetworkRequest(peers[randomPeer3])
    ]);

    for(var i = 0; i < responses.length; i++){
      if(i == 0
      && responses[i] == htmlErrorData){
        randomPeer1 = random.nextInt(32);
        while(randomPeer1 == randomPeer2 ||
            randomPeer1 == randomPeer3){
          randomPeer1 = random.nextInt(32);
        }

        responses[0] = await
        performNetworkRequest(peers[randomPeer1]);
      }

      if(i == 1
          && responses[i] == htmlErrorData){
        randomPeer2 = random.nextInt(32);
        while(randomPeer2 == randomPeer1 ||
            randomPeer2 == randomPeer3){
          randomPeer2 = random.nextInt(32);
        }

        responses[1] = await
        performNetworkRequest(peers[randomPeer2]);
      }

      if(i == 2
          && responses[i] == htmlErrorData){
        randomPeer3 = random.nextInt(32);
        while(randomPeer3 == randomPeer1 ||
            randomPeer3 == randomPeer2){
          randomPeer3 = random.nextInt(32);
        }

        responses[2] = await
        performNetworkRequest(peers[randomPeer3]);
      }
    }

    if((responses[0] == responses[1]) && (responses[1] == responses[2])){
      if(responses[0] == null || responses[0].isEmpty == 0){
        setState(() {
          htmlData = htmlErrorData;
        });
      }else{
        setState(() {
          htmlData = responses[0];
        });
      }
    }else{
      setState(() {
        htmlData = htmlErrorData;
      });
    }

  }

  Future<String> performNetworkRequest(String peer) async {
    String? responseData;
    var url = Uri.parse("$peer/v1/chain/get_table_rows");
    var response;
     try {
       response = await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'code': tce.text,
          'table': tce.text,
          'scope': tce.text,
          'json': true
        }),);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

    }catch(Exception){
       response = null;
    }

      try {

        var parsed = json.decode(response.body);
        responseData = parsed["rows"][0]["domainvalue"];

      } on FormatException catch (e) {
        print("That string didn't look like Json.");
        responseData = htmlErrorData;

      } on NoSuchMethodError catch (e) {
        print('That string was null!');
        responseData = htmlErrorData;
      }
      return responseData ?? htmlErrorData;
  }


  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  width: 200,
                  height: 50,
                  child: Form(
                    key: _formKey,
                    child: TextField(
                      controller: tce,
                      autofocus: true,
                      onSubmitted: (value){
                        print(tce.text);
                        setState(() {
                          performRedundancyNetworkRequests();
                        });
                        Navigator.pop(context);
                      },
                      textInputAction: TextInputAction.search,)
                  )
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                print(tce.text);
                setState(() {
                  performRedundancyNetworkRequests();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //TODO handle this
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _showMyDialog(),
        child: Scaffold(
          body: Container(
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        SizedBox(height: 50),
                        Html(
                          data: htmlData,
                          onLinkTap: (url, _, __, ___) {
                            print("Opening $url...");
                            launchURL(url!);
                          },
                        ),
                      ]
                  )
              )
          ),
        )
    );
  }
}

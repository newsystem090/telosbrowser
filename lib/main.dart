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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telos Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Telos Browser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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
  bool twoConfirmations = false;
  bool oneConfirmation = false;
  bool isLoading = false;
  String htmlErrorData = "<html><div>network issue</div></html>";

  void performRedundancyNetworkRequests() async {

    setState(() {
      isLoading = true;
    });

    oneConfirmation = false;
    twoConfirmations = false;

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

    // all confirmations successful
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
    }
    // confirmations are partially successful, return response with most confirmations
    else{
      if(responses[0] == responses[1] && responses[0] != null){
        setState(() {
          twoConfirmations = true;
          htmlData = responses[0];
        });
      }else if(responses[0] == responses[2] && responses[0] != null){
        setState(() {
          twoConfirmations = true;
          htmlData = responses[0];
        });
      }else if(responses[1] == responses[2] && responses[1] != null){
        setState(() {
          twoConfirmations = true;
          htmlData = responses[1];
        });
      }else if(responses[0] != null){
        setState(() {
          oneConfirmation = true;
          htmlData = responses[0];
        });
      }else if(responses[1] != null){
        setState(() {
          oneConfirmation = true;
          htmlData = responses[1];
        });
      }else if(responses[2] != null){
        setState(() {
          oneConfirmation = true;
          htmlData = responses[2];
        });
      }else{
        setState(() {
          htmlData = htmlErrorData;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
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
                  child: (isLoading)?
                      Column(
                        children: [
                          SizedBox(height: 300),
                          Container(
                            alignment: Alignment.center,
                              child: CircularProgressIndicator()
                          )
                        ]
                      ) :
                  (htmlData.isEmpty)?
                  Column(
                      children: [
                        SizedBox(height: 300),
                        Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.search, size: 30,)
                        ),
                        SizedBox(height: 10),
                        Container(
                            alignment: Alignment.center,
                            child: Text('Search')
                        )
                      ]
                  ) :
                  Column(
                      children: [
                        SizedBox(height: 50),
                        (oneConfirmation)?
                        _buildPartialConfirmationWarning(1)
                            : (twoConfirmations)?
                        _buildPartialConfirmationWarning(2)
                            : Container(),
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

  Widget _buildPartialConfirmationWarning(int confirmations){
    return Container(
          padding: EdgeInsets.only(left: 18, right: 18, top: 23, bottom: 18),
          margin: EdgeInsets.only(bottom: 10),
          color: Colors.amber,
          height: 60,
          child: Text('response has was partially confirmed with $confirmations confirmation${(confirmations != 1)? 's' : ''}', softWrap: true,
              style: TextStyle(
                fontSize: 12,
              ))
    );
  }
}

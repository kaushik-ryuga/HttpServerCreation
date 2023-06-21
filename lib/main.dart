import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() async{
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String statusText = 'Start Server';
  HttpServer? server;

  startServer() async {
    final wifiIp = await NetworkInfo().getWifiIP();
    server = await HttpServer.bind(InternetAddress(wifiIp!), 8080);

    print(
        'Server running on IP: ${server!.address.toString()} on Port: ${server!.port.toString()}');

    await for (var request in server!) {
      handleRequest(request);
    }
  }

  Future<void> handleRequest(HttpRequest request) async {
    if(request.method == 'GET' && request.uri.path == '/api/hello') {
      final response = request.response;
      response.headers.contentType = ContentType.json;
      response.write('hi this is kaushik welcome to my world');
      response.close();
    }
    else if (request.uri.path == '/api/download') {
      print('finding the file');
      final file = File('resources/ryuga.jpg');

      if(file.existsSync()) {
        request.response.headers.contentType = ContentType.binary;
        final fileStream = file.openRead();
        await fileStream.pipe(request.response);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.writeln('File not found');
      }
    }
    else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.close();
    }
  }

  void stopServer() {
    server!.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Start Server'),
              onPressed: () async{
                startServer();
                // final response = await http.get(Uri.parse('${server!.address.toString()}:5050'));
                setState(() {
                  statusText = 'server is running..... and ip is ${server!.address.toString()}';
                });
              },
            ),

            Text(statusText),

            ElevatedButton(
              child: const Text('Stop Server'),
              onPressed: () async{
                stopServer();
                setState(() {
                  statusText = 'server stopped';
                });
              },
            ),


          ],
        ),
      ),
    );
  }
}
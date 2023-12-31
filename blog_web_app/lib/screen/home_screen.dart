import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatelessWidget{
  WebViewController? controller;
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Seong Eun'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: (){
              if (controller != null){
                controller!.loadUrl('https://velog.io/@bongfam2');
              }
            },
            icon: Icon(
              Icons.home,
            ),
          ),
        ],

      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller) {
          this.controller = controller;
        },
        initialUrl: 'https://velog.io/@bongfam2',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
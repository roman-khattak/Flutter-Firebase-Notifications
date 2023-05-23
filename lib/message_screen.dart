import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String id ;
  const MessageScreen({Key? key , required this.id}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Message Screen' +widget.id)  ,
      ),

      body: Center(
        child: const Text(
            "Hi there, you are redirected to message screen after cliking on the Firebase notification"
        ),
      ),

    );
  }
}

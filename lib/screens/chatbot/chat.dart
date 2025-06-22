import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;

class Basic extends StatefulWidget {
  final String? token;
  final String? chattoken;
  final int? user;
  final int? chatid;
  final Function goto;
  const Basic({super.key, this.token, this.user, this.chatid, this.chattoken, required this.goto});

  @override
  BasicState createState() => BasicState();
}

class BasicState extends State<Basic> {
  final _chatController = InMemoryChatController();
  String _responseContent = "";
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    getContent();
  }

  void getContent() async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/chatbot/messages/?session=${widget.chatid}&ordering=created_at"), headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    _chatController.setMessages([]);
    for (var item in decodedResponse['items']) {
      if (item['session'] == widget.chatid) {
        _chatController.insertMessage(
            TextMessage(
              id: "${item['id']}",
              authorId: item['sender'],
              createdAt: DateTime.parse(item['created_at']),
              text: item['message'],
            ),
          );
      }
    }
  }

  void sendHandler(String message) async {
    var request = http.Request('POST', Uri.parse("https://smart-cart-backend.up.railway.app/api/chatbot/interaction/send_message/"));
    request.body =
      '{ "message": "$message", "session_token": "${widget.chattoken}"}';
    request.headers.clear();
    request.headers.addAll({HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'});
    var response = await request.send();
    _responseContent = "";
    response.stream.listen((List<int> stream) {
      _responseContent += utf8.decode(stream);
      print('resultado');
      print(_responseContent);
    },
    onDone: () {
      print('fin');
      print(message);
      print(response.statusCode);
      print(response.headers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        chatController: _chatController,
        currentUserId: 'user',
        onMessageSend: (text) {
          _chatController.insertMessage(
            TextMessage(
              id: '${Random().nextInt(1000) + 1}',
              authorId: 'user',
              createdAt: DateTime.now(),
              text: text,
            ),
          );
          sendHandler(text);
        },
        resolveUser: (UserID id) async {
          return User(id: id, name: 'John Doe');
        },
      ),
    );
  }
}
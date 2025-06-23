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
    List<Message> messages = [];
    for (var item in decodedResponse['items']) {
      if (item['session'] == widget.chatid) {
        messages.add(
            TextMessage(
              id: "${item['id']}",
              authorId: item['sender'],
              createdAt: DateTime.parse(item['created_at']),
              text: item['message'],
            ),
          );
      }
    }
    _chatController.setMessages(messages);
  }

  void sendHandler(String message) async {
    await http.post(Uri.parse("https://smart-cart-backend.up.railway.app/api/chatbot/interaction/send_message/"),
    body: '{ "message": "$message", "session_token": "${widget.chattoken}"}',
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'});
    getContent();
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
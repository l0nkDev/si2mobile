import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class ChatList extends StatefulWidget{
  final String? token;
  final int? user;
  final Function goto;
  final Function setchat;
  const ChatList({super.key, this.token, this.user, required this.goto, required this.setchat});

  @override
  State<ChatList> createState() => _CartState();
}

class _CartState extends State<ChatList> {
  late Future<dynamic> chatsFuture;

  Future<dynamic> getChats() async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/chatbot/sessions/"), headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var items = [];
    for (var item in decodedResponse["items"]) {
      if (item['user'] == widget.user) items.add(item);
    }
    return items.reversed.toList();
  }

  String genToken(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void createChat() async {
    final response = await http.post(Uri.parse("https://smart-cart-backend.up.railway.app/api/chatbot/sessions/"), 
    body: 
      '''
      {
        "user": ${widget.user},
        "session_token": "${genToken(8)}-${genToken(4)}-${genToken(4)}-${genToken(4)}-${genToken(12)}",
        "active": "true"
      }
      ''',
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"});
    print(response.body);
    chatsFuture = getChats();
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    chatsFuture = getChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: 
            Column(
              children: <Widget>[
                ElevatedButton(onPressed: createChat, child: Text('+')),
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: chatsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return buildChats(products, widget.goto, widget.setchat);
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [const Text("Cargando...")],
                        );
                      }
                    }
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget buildChats(dynamic cartitems, Function goto, Function setchat) => ListView.builder(
    itemCount: cartitems.length,
    itemBuilder: (context, index) {
      final tmp = cartitems as List<dynamic>;
      final item = tmp[index];
      return chatsItem(item: item, goto: goto, setchat: setchat);
    }
  );
}

class chatsItem extends StatelessWidget {
  chatsItem({
    super.key,
    required this.item,
    required this.goto,
    required this.setchat,
  });

  final dynamic item;
  final Function goto;
  final Function setchat;
  final TextEditingController quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() {setchat(item['session_token']); goto(8, y: item["id"]);},
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text("Chat ${item["id"]}"),
              subtitle: Text(item["updated_at"]),
            ),
          ],
        )
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class UserFeedback extends StatefulWidget{
  UserFeedback(this.id, this.token, {super.key});
  final int id;
  final String? token;

  @override
  State<UserFeedback> createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  late Future<List> feeedbackFuture;

  Future<List> getFeedback() async {
    List currentitems = [];
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/feedback/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var items = decodedResponse["items"];
    for (var item in items) {
      if (item['order'] == widget.id) currentitems.add(item);
    }
    print(currentitems);
    return currentitems;
  }

  Future<String> product(int id) async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/products/$id/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    print(decodedResponse);
    return decodedResponse['name'];
  }

  @override
  initState() {
    super.initState();
    feeedbackFuture = getFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

  return Scaffold(
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 32,),
        Text("Valoración del pedido", style: style),
        SizedBox(height: 24,),
        Row(
          children: [
            SizedBox(width: 24),
            Text("Productos", style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500))
          ]
        ),
        Expanded(
          child: FutureBuilder<List>(
            future: feeedbackFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!;
                for (Map item in items) {
                  if (item['delivery_rating'] != null) {
                    items.remove(item);
                    items.add(item);
                  }
                }
                return buildFeedback(items, theme, product);
              } else {
                return const Text("No data");
              }
            }
          ),
        ),
      ],
    ),
  );
}
}

Widget buildFeedback(List items, ThemeData theme, Function getProduct) => ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return FeedbackCard(item: item, theme: theme, getProduct: getProduct,);
  }
);

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({
    super.key,
    required this.theme,
    required this.item,
    required this.getProduct,
  });

  final ThemeData theme;
  final Map item;
  final Function getProduct;

  @override
  Widget build(BuildContext context) {
    late Future<String> productname = getProduct(item['product']);
    TextEditingController c = TextEditingController();
    c.value = TextEditingValue(text: item['product'] == null ? item['delivery_comment'] : item['product_comment']);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Card(
        child: Column(
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                if (item['product'] != null) FutureBuilder<String>(
                  future: productname,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final name = snapshot.data!;
                      print('futurebuilder');
                      print('name');
                      return SizedBox(width: 200, child: Text(name , style: theme.textTheme.bodyLarge));
                    }
                    return Text('');
                  }
                ),
                if (item['product'] == null) Text("Delivery", style: theme.textTheme.bodyLarge),
                  Expanded(child: Text("")),
                  Text("★★★☆☆", style: theme.textTheme.headlineSmall!.copyWith(color: Color(0xFF01687D))),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(width: 16),
                if (item['product'] == null) Text("¿Cómo fue el servicio de delivery?"),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 96,
                child: Expanded(
                  child: TextField(
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Reseña'),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical(y: -1),
                    controller: c,
                    ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 8),
                OutlinedButton( onPressed: null, child: Text("Enviar")),
              ],
            ),
            SizedBox(height: 8)
          ],
        ),
      ),
    );
  }
}
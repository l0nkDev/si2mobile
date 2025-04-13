import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Catalogue extends StatelessWidget{
  final String token;
  Catalogue(this.token);

  Future<List> loadProducts(String token) async {
    var products = [];

    var response = await http.get(Uri.parse("https://dismac-backend.up.railway.app/products/"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"}
    );

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (response.statusCode != 200) {
      return [{"name": "Not logged in", "description": "Nonexistant, expired or invalid token", "image_url": "https://i.imgur.com/yd01iL2.jpeg"}];
    }
    for (var item in decodedResponse["items"]) {
      products.add(
        {
          "name": item["name"],
          "description": item["description"],
          "image_url": item["image_url"],
        }
        );
    }
    print(products);
    return products;
  }

  @override
  Widget build(BuildContext context) {
    loadProducts(token);


    return Scaffold(
      body: ListView(
        children: [
          FutureBuilder<List>(
            future: loadProducts(token),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    for (var item in snapshot.data!)
                      CatalogueItem(name: item["name"], description: item["description"], imageurl: item["image_url"],)
                  ],
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}

class CatalogueItem extends StatelessWidget {
  const CatalogueItem({
    super.key,
    required this.name,
    required this.description,
    this.imageurl = "https://i.imgur.com/yd01iL2.jpeg",
  });

  final String name;
  final String description;
  final String imageurl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                Image.network(imageurl, width: 150, height: 150),
                SizedBox(
                    width: 237,
                    child: Column(
                      children: [
                        Text(name, style: style.headlineSmall),
                        Text(description),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
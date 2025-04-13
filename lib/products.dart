import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Products extends StatelessWidget{
  final String token;
  Products(this.token);

  Future<List> loadProducts(String token) async {
    var products = [];

    var response = await http.get(Uri.parse("https://dismac-backend.up.railway.app/products/inventory?page_size=100"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer $token"}
    );

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (response.statusCode != 200) {
      return [{"name": "Not logged in", "description": "Nonexistant, expired or invalid token", "image_url": "https://i.imgur.com/yd01iL2.jpeg", "id": "", "stock": "", "product_id": "", "price_usd": "", "price_bs": "", "brand": "", "category": "", "technical_specifications": ""}];
    }
    for (var item in decodedResponse["items"]) {
      products.add(
        {
          "name": item["product"]["name"] ?? "null",
          "description": item["product"]["description"] ?? "null",
          "id": item["product"]["id"] ?? "null",
          "stock": item["stock"] ?? "null",
          "product_id": item["product_id"] ?? "null",
          "price_usd": item["price_usd"] ?? "null",
          "price_bs": item["price_bs"] ?? "null",
          "brand": item["product"]["brand"] == null ? "null" : item["product"]["brand"]["name"],
          "category": item["product"]["category"] == null ? "null" : item["product"]["category"]["name"],
          "technical_specifications": item["product"]["technical_specifications"] ?? "null",
          "image_url": item["product"]["image_url"] ?? "https://i.imgur.com/yd01iL2.jpeg",
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
                      CatalogueItem(name: item["name"], description: item["description"], imageurl: item["image_url"], id: item["id"].toString(), stock: item["stock"].toString(), productId: item["product_id"].toString(), priceUsd: item["price_usd"].toString(), priceBs: item["price_bs"].toString(), brand: item["brand"], category: item["category"], technicalSpecifications: item["technical_specifications"],)
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
    required this.id,
    required this.stock,
    required this.productId,
    required this.priceUsd,
    required this.priceBs,
    required this.brand,
    required this.category,
    required this.technicalSpecifications,
    this.imageurl = "https://i.imgur.com/yd01iL2.jpeg",
  });

  final String name;
  final String description;
  final String id;
  final String stock;
  final String productId;
  final String priceUsd;
  final String priceBs;
  final String brand;
  final String category;
  final String technicalSpecifications;
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
                Image.network(imageurl, width: 50, height: 50),
                SizedBox(
                    width: 237,
                    child: Column(
                      children: [
                        Text(name, style: style.bodyLarge),
                        Text("Descripcion: $description"),
                        Text("ID: $id"),
                        Text("ID de producto: $productId"),
                        Text("Stock disponible: $stock"),
                        Text("Precio en USD: \$$priceUsd"),
                        Text("Precio en Bs.: Bs. $priceBs"),
                        Text("Marca: $brand"),
                        Text("Categoria: $category"),
                        Text("Especificaciones técnicas: $technicalSpecifications")
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
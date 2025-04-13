import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:si2mobile/main.dart';

class Catalogue extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    var products = [];
    loadProducts(context.watch().token);

    return Scaffold(
      body: Column(
        children: [
          for (var product in products)
            Card(
              child: Column(
                children: [
                  Text(""),
                ],
              ),
            )
        ],
      ),
    );
  }

  void loadProducts(String token) async {
          Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
      'Authorization': token
    };
    
      var response = await http.get(Uri.https("dismac-backend.up.railway.app", 'products'), 
      headers: headers
    );
  }

}
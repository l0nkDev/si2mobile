import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class Purchases extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  const Purchases({super.key, this.token, required this.isLogged, required this.goto});

  @override
  State<Purchases> createState() => _PurchasesState();
}

class _PurchasesState extends State<Purchases> {
  bool speechEnabled = false;
  late Future<List> productsFuture;
  TextEditingController search = TextEditingController();

  Future<List> getProducts() async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/finance/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var items = decodedResponse["items"];
    print(items);
    return items;
  }

  @override
  void initState() {
    super.initState();
    productsFuture = getProducts();
  }

  rateDelivery(int id, double rating) async {
    final response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/purchases/rate"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"},
    body: '''{"id": "$id", "rating": "$rating"}'''
    );
    print(response.body);
    productsFuture = getProducts();
    setState(() {});
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
                Expanded(
                  child: FutureBuilder<List>(
                    future: productsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return buildPurchases(products, widget.isLogged);
                      } else {
                        return const Text("No data");
                      }
                    }
                  ),
                )
              ]
            )
          );
        }
      ),
    );
  }

  Widget buildPurchases(List products, bool isLogged) => ListView.builder(
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];

      return PurchaseCard(product: product, rate: rateDelivery);
    }
  );

  addToCart(Purchase prod, BuildContext context) async {
    var response = await http.post(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"id": "${prod.id}"}'
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod.delivery_status}\" fue agregado al carrito.")));
  }
}

class PurchaseCard extends StatelessWidget {
  PurchaseCard({
    super.key,
    required this.product,
    required this.rate,
  });

  final dynamic product;
  final Function rate;
  final TextEditingController quantity = TextEditingController();

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    quantity.value = TextEditingValue(text: '5');
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text("Pedido #${product["id"]}"),
          ),
          for (dynamic item in product["items"]) Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 15,),
                  Text(item["product"]["name"]),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 15,),
                  Text("x${item["quantity"]}"),
                ],
              ),
              SizedBox(height: 15,),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Total: \$${product["total_amount"]}"),
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Metodo de pago: ${product["payment"]["payment_method"]}"),
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Estado de pago: ${product["payment"]["payment_status"]}"),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Estado del pedido: ${product["delivery"]["status_display"]}     "),
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Marcar como: "),
              ElevatedButton(child: Text("En Reparto"), onPressed: () {}),
              ElevatedButton(child: Text("Entregado"), onPressed: () {})
            ],
          ),
          SizedBox(height: 30,),
        ],
      )
    );
  }
}
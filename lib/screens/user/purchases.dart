import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      return PurchaseCard(product: product, rate: rateDelivery, set: setDelivery, get:getReceipt, goto:widget.goto,);
    }
  );

  
  setDelivery(int order, String status) async {
    var response = await http.patch(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/deliveries/$order/"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '{"delivery_status": "$status"}'
    );
    print(response.body);
    productsFuture = getProducts();
    setState(() {});
  }

  void getReceipt(int id, {bool attempted = false}) async {
    http.Response response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/reports/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    Map decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    List items = decodedResponse["items"];
    for (Map item in items) {
      if (item['format'] == 'pdf' && item['report_type'] == 'order_receipt' && item['report_data'] != null && item['report_data']['order'] != null && item['report_data']['order']['order_id'] == id) {
        _launchUrl(item['file_path']);
        print('found');
        return;
      }
    }
    print('failed');
    if (!attempted) createReceipt(id);
  }

  void createReceipt(int id) async {
    http.Response response = await http.post(Uri.parse("https://smart-cart-backend.up.railway.app/api/reports/"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '''
          {
            "name": "Recibo de mi pedido", 
            "report_type": "order_receipt", 
            "format": "pdf", 
            "language": "es", 
            "order_id": $id
          }
            '''
    );
    if (response.statusCode != 200) { print(response.body); return; }
    getReceipt(id, attempted: true);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}

class PurchaseCard extends StatelessWidget {
  PurchaseCard({
    super.key,
    required this.product,
    required this.rate,
    required this.set,
    required this.get,
    required this.goto,
  });

  final dynamic product;
  final Function rate;
  final Function set;
  final Function get;
  final Function goto;
  final TextEditingController quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    quantity.value = TextEditingValue(text: '5');
    if (product["payment"] == null) return SizedBox();
    if (product["delivery"] == null) return SizedBox();
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Text("Pedido #${product["id"]}"),
                Spacer(),
              if (product["delivery"]["delivery_status"] == 'delivered') ElevatedButton(child: Text("Feedback"), onPressed: () { goto(6, y: product["id"]); }),
              ElevatedButton(child: Text("Factura"), onPressed: () {get(product["id"]);}),
              ],
            ),
          ),
          for (dynamic item in product["items"]) 
          if (item["payment"] != null)
          Column(
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
              if(product["delivery"] == null) Text("Estado del pedido:   Ninguno")
              else Text("Estado del pedido: ${product["delivery"]["status_display"]}     "),
            ],
          ),
          SizedBox(height: 15,),
          Row(
            children: [
              SizedBox(width: 15,),
              Text("Marcar como: "),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              ElevatedButton(child: Text("Pendiente"), onPressed: () {set(product["id"], "pending");}),
              ElevatedButton(child: Text("Procesando"), onPressed: () {set(product["id"], "processing");}),
              ElevatedButton(child: Text("En Reparto"), onPressed: () {set(product["id"], "out_for_delivery");}),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15,),
              ElevatedButton(child: Text("Entregado"), onPressed: () {set(product["id"], "delivered");}),
              ElevatedButton(child: Text("Fallido"), onPressed: () {set(product["id"], "failed");}),
            ],
          ),
          SizedBox(height: 30,),
        ],
      )
    );
  }
}
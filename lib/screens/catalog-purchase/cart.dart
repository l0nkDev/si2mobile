import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/cart.dart';
import 'package:url_launcher/url_launcher.dart';



class CartScreen extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  const CartScreen({super.key, this.token, required this.isLogged, required this.goto});

  @override
  State<CartScreen> createState() => _CartState();
}

class _CartState extends State<CartScreen> {
  double? total;
  late Future<dynamic> cartsFuture;
  String vip = '';
  int cartid = 0;
  TextEditingController search = TextEditingController();

  Future<dynamic> getCart() async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/finance/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var items = decodedResponse["items"];
    print(items);
    for (var item in items) {
      if (item['payment'] == null) {
        cartid = item["id"];
        return item;
      }
    }
    return null;
  }

  @override
  initState() {
    super.initState();
    cartsFuture = getCart();
  }

  updateCart(int id, int quantity) async {
    double sum = 0;
    await http.patch(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/add"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"},
    body: '''{"id": "$id", "quantity": "$quantity"}'''
    );
    total = 0;
    cartsFuture = getCart();
    getCart().then((value) => {
      for (var item in value) {
        if (item.product.discount == 0) { sum += item.product.price * item.quantity }
        else { if (item.product.discount_type == 'P') { sum += item.quantity * (item.product.price * (1 - (item.product.discount * 0.01))) } else { sum += item.quantity * (item.product.price - item.product.discount) }}
      },
      setState(() {
        total = sum;
      })
    });
    setState(() {});
  }

  deleteCart(int id) async {
    print("ID: $id");
    double sum = 0;
    final response = await http.delete(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart/remove?id=$id"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"}
    );
    final body = json.decode(response.body);
    print(body);
    total = 0;
    cartsFuture = getCart();
    getCart().then((value) => {
      for (var item in value) {
        if (item.product.discount == 0) { sum += item.product.price * item.quantity }
        else { if (item.product.discount_type == 'P') { sum += item.quantity * (item.product.price * (1 - (item.product.discount * 0.01))) } else { sum += item.quantity * (item.product.price - item.product.discount) }}
      },
      setState(() {
        total = sum;
      })
    });
    setState(() {});
  }

  emptyCart() async {
    final response = await http.delete(Uri.parse("http://l0nk5erver.duckdns.org:5000/users/cart"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"}
    );
    final body = json.decode(response.body);
    print(body);
    total = 0;
    cartsFuture = getCart();
  }

  payCart(int id) async {
    final response = await http.post(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/stripe-checkout/"),
    headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: "application/json"},
    body:
    '''
    {
      "order_id": "$id"
    }
    '''
    );
    print(utf8.decode(response.bodyBytes));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    _launchUrl(Uri.parse(decodedResponse["checkout_url"]));
    widget.goto(0);
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
                ElevatedButton(onPressed: widget.isLogged ? () {widget.goto(0);} : null, child: Text("Volver al catálogo")),
                Expanded(
                  child: FutureBuilder<dynamic>(

                    future: cartsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final products = snapshot.data!;
                        return buildCart(products, widget.isLogged);
                      } else {
                        return const Text("No data");
                      }
                    }
                  ),
                ),
                Column(
                  children: [
                    Row(mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(onPressed: widget.isLogged ? () {emptyCart();} : null, child: Text("Vaciar carrito")),
                        ElevatedButton(onPressed: widget.isLogged ? () {print("Cart id es: $cartid"); payCart(cartid);} : null, child: Text("Pagar")),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget buildCart(dynamic cartitems, bool isLogged) => ListView.builder(
    itemCount: cartitems["items"].length,
    itemBuilder: (context, index) {
      final tmp = cartitems["items"] as List<dynamic>;
      final item = tmp[index];
      return cartItem(item: item, cartUpdate: updateCart, cartRemove: deleteCart);
    }
  );
}

class cartItem extends StatelessWidget {
  cartItem({
    super.key,
    required this.item,
    required this.cartUpdate,
    required this.cartRemove,
  });

  final dynamic item;
  final Function cartUpdate;
  final Function cartRemove;
  final TextEditingController quantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(item["quantity"]);
    print(item["id"]);
    quantity.value = TextEditingValue(text: "${item["quantity"]}");
    return Card(
      child: Column(
        children: [
          ListTile(
              leading: Image.network(item["product"]["image_url"],
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    final totalBytes = loadingProgress?.expectedTotalBytes;
                    final bytesLoaded =
                        loadingProgress?.cumulativeBytesLoaded;
                    if (totalBytes != null && bytesLoaded != null) {
                      return CircularProgressIndicator(
                        backgroundColor: Colors.white70,
                        value: bytesLoaded / totalBytes,
                        color: Colors.blue[900],
                        strokeWidth: 5.0,
                      );
                    } else {
                      return child;
                    }
                  },
                  frameBuilder: (BuildContext context, Widget child,
                      int? frame, bool wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
         
                   return const Text('😢');
                  },
                ),
            title: Text(item["product"]["name"]),
            subtitle: Text(item["product"]["brand"]["name"]),
          ),
          Row(
            children: [
              SizedBox(width: 15),
              Text(item["product"]["description"]),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15),
              Text("✰${item["product"]["average_rating"]}"),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 15),
              Text("\$${item["product"]["price_usd"]}"),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Text("Cantidad: "),
                Expanded(child: TextField(controller: quantity)),
                ElevatedButton(
                  onPressed: () {cartUpdate(item.id, int.parse(quantity.value.text));}, 
                  child: Text("Guardar"), 
                  ),
                ElevatedButton(
                  onPressed: () {cartRemove(item.id);}, 
                  child: Text("Eliminar"), 
                  ),
              ],
            ),
          ) 
        ],
      )
    );
  }
}
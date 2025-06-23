import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class Catalogue extends StatefulWidget{
  final String? token;
  final bool isLogged;
  final Function goto;
  final Function setItemUrl;
  const Catalogue({super.key, this.token, required this.isLogged, required this.goto, required this.setItemUrl});

  @override
  State<Catalogue> createState() => _CatalogueState();
}




class _CatalogueState extends State<Catalogue> {
  bool speechEnabled = false;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  TextEditingController search = TextEditingController();
  String _lastWords = '';
  
  List<dynamic> products  = [];
  int nextPage = 1;
  
  ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  void loadNextPage() {
    getProducts(nextPage++, search.text).then((newProducts){
      products.addAll(newProducts);
      itemCount.value = products.length;
    });
  }

  Future<List<dynamic>> getProducts(int page, String query) async {
    if (query == '') {
      http.Response response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/products?page=$page"), 
        headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'});
        Map decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return response.statusCode == 200 ? decoded["items"] : [];
        }
    else {
      if (page != 1) return [];
      http.Response response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/products/similar/?query=$query&count=8"), 
        headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'});
      List decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded;
      }
  }

    @override
  initState() {
    super.initState();
    _initSpeech();
    loadNextPage();
  }

  Map getProductAtIndex(int index) {
    if (index > products.length - 5) {
      loadNextPage();
    }
    return products[index];
  }

  void _initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

    void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, partialResults: false, localeId: "es_ES");
    setState(() {});
  }

    void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

    void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {_lastWords = result.recognizedWords;}); 
    search.value = TextEditingValue(text: _lastWords);
    products = [];
    nextPage = 1;
    itemCount.value = 0;
    loadNextPage();
  }

    void recommend(String query) {
      setState(() { search.value = TextEditingValue(text: query); });
      products = [];
      nextPage = 1;
      itemCount.value = 0;
      loadNextPage();
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
                Row(
                  children: [
                    Expanded(child: 
                      TextField(
                        controller: search,
                        decoration: InputDecoration(border: OutlineInputBorder()),
                      )
                    ),
                    ElevatedButton(onPressed: () {
                      products = [];
                      nextPage = 1;
                      itemCount.value = 0;
                      loadNextPage();
                      }, child: Icon(Icons.search)),
                    ElevatedButton(
        onPressed:
            _speechToText.isNotListening ? _startListening : _stopListening,
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),),
                    ElevatedButton(onPressed: widget.isLogged ? () {widget.goto(2);} : null, child: Icon(Icons.shopping_cart)),
                  ],
                ),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: itemCount,
                    builder: (BuildContext context, int value, Widget? child) {
                      return buildProducts(products, widget.isLogged, widget.goto, widget.setItemUrl, recommend);
                    }
                  ),
                )
              ]
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {widget.goto(7);},
        child: Icon(Icons.chat),
      )
    );
  }

  Widget buildProducts(List<dynamic> products, bool isLogged, Function goto, Function setItemUrl, Function recommend) => ListView.builder(
      itemCount: itemCount.value,
      itemBuilder: (context, index) {
      final product = getProductAtIndex(index);

      return Card(
        child: Column(
          children: [
            ListTile(
              leading: Image.network(product["image_url"],
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
              title: Text(product["name"]),
              subtitle: Text(product["brand"]["name"]),
            ),
            Row(
              children: [SizedBox(width: 15,),
                Text("✰${product["average_rating"] ?? "---"}"),
              ],
            ),
            Row(
              children: [SizedBox(width: 15,),
                Text("\$${product["price_usd"]}")
              ],
            ),
            Row( mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: isLogged ? () { addToCart(product, context); } : null, 
                  child: Icon(Icons.add_shopping_cart), 
                  ),
                if (product['model_3d_url'] != null) ElevatedButton(
                  onPressed: () { setItemUrl(product['model_3d_url']); goto(10); }, 
                  child: Text("AR"), 
                ),
              ],
                ),
            ElevatedButton(
              onPressed: () { recommend(product["name"]); }, 
              child: Text("☆ Mostrar recomendaciones"), 
            ),
          ],
        )
      );
    }
  );

  addToCart(Map prod, BuildContext context) async {
    var response = await http.post(Uri.parse("https://smart-cart-backend.up.railway.app/api/orders/finance/"), 
      headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}", HttpHeaders.contentTypeHeader: 'application/json'},
      body: '''
          {
            "currency": "USD",
            "items": [
              {
                "product_id": ${prod["id"]},
                "quantity": 1
              }
            ]
          }
            '''
    );
    print(response.body);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("\"${prod["name"]}\" fue agregado al carrito.")));
  }
}
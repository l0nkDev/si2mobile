import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Login extends StatelessWidget{
  final ValueListenable<String> token;

  Login(this.token);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    TextEditingController email = TextEditingController();
    TextEditingController passwd = TextEditingController();

    return Scaffold(
      body: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Inicio de sesión", style: style),
              LabeledInput(label: "e-mail", controller: email,),
              LabeledInput(label: "Contraseña", controller: passwd),
              FilledButton(
                child: Text("Iniciar sesión"),
                onPressed: () {
                  sendLogin(email.value.text, passwd.value.text, context, token);
                })
            ],
          ),
        ),
      ),
      );
  }
}

Future<void> sendLogin(String email, String password, BuildContext context, ValueListenable<String> token) async {

      Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
      var response = await http.post(Uri.https("dismac-backend.up.railway.app", 'auth/login/email'), 
      headers: headers,
      body: 
      '''
        {
          "email": "$email",
          "password": "$password"
        }
    '''
    );
    print(response.body);
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sesión iniciada correctamente como user ${decodedResponse["user_id"]}")),
    );
    token.value = decodedResponse["access_token"];
    print(context.watch().token);
}

class LabeledInput extends StatelessWidget {
    const LabeledInput({
    super.key,
    required this.label,
    required this.controller
    });

    final String label;
    final TextEditingController controller;

  @override
  Widget build(BuildContext context) {

    return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: 
                  InputDecoration(
                    label: Text(label),
                    border: OutlineInputBorder()
                    ),
                )
              ],
            ),
          );
  }
}
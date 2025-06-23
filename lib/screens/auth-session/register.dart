import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:si2mobile/firebase_api.dart';
import '../../components/labeledInput.dart';

class Register extends StatelessWidget{
  final Function setToken;
  final Function setUser;
  final Function goto;
  const Register(this.setToken, this.setUser, this.goto, {super.key});



  Future<void> sendRegistration(String email, String password, String name, String lname, BuildContext context) async {
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
    };
    
    var response = await http.post(Uri.parse('https://smart-cart-backend.up.railway.app/api/auth/users/'), 
      headers: headers,
      body: 
      '''
        {
          "active": true,
          "email": "$email",
          "first_name": "$name",
          "is_staff": true,
          "is_superuser": false,
          "last_name": "$lname",
          "password": "$password",
          "role": "customer"
        }
    '''
    );
    sendLogin(email, password, context);
}



Future<void> sendLogin(String email, String password, BuildContext context) async {
  Map<String,String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };
  
    var response = await http.post(Uri.https("smart-cart-backend.up.railway.app", 'api/auth/login/'), 
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
  if (response.statusCode == 200) {
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sesión iniciada correctamente.")),
    );
    setToken(decodedResponse["access"]);
    setUser(decodedResponse["id"]);
    goto(0);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No se pudo iniciar sesión.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.headlineMedium!;

    TextEditingController email = TextEditingController();
    TextEditingController passwd = TextEditingController();
    TextEditingController name = TextEditingController();
    TextEditingController lname = TextEditingController();

    return Scaffold(
      body: Card(
        child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32,),
                  Text("Crear cuenta", style: style),
                  LabeledInput(label: "Nombre", controller: name),
                  LabeledInput(label: "Apellido", controller: lname),
                  LabeledInput(label: "e-mail", controller: email,),
                  LabeledInput(label: "Contraseña", controller: passwd),
                  FilledButton(
                    child: Text("Registrate!"),
                    onPressed: () {
                      sendRegistration(email.value.text, passwd.value.text, name.value.text, lname.value.text, context);
                    }),
                  SizedBox(height: 32,),
                  Text("Ya tienes cuenta?"),
                  OutlinedButton(
                    child: Text("Inicia Sesión"),
                    onPressed: () {
                      goto(1);
                    })
                ],
              ),
            ],
          ),
        ),
      );
  }
}
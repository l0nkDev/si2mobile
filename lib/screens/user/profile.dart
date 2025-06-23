import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class Profile extends StatefulWidget{
  final String token;
  Profile(this.token, {super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loaded = false;
  Map user = {};
  Map userdata = {};

  void getUser() async {
    final response = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/auth/loyalty/me/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    final body = json.decode(response.body) as Map;
    final response2 = await http.get(Uri.parse("https://smart-cart-backend.up.railway.app/api/auth/users/${body['user']}/"),headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    final body2 = json.decode(response2.body) as Map;
    user = body;
    userdata = body2;
    loaded = true;
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    final style = theme.textTheme.bodyLarge!;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ifLoaded(loaded, style)
      ),
    );
  }

  Widget ifLoaded(bool loaded, TextStyle style) {
    if (loaded) {
      return Column(
        children: [
          Row(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Tu nivel de lealtad', style: style.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nivel actual:', style: style),
                      ElevatedButton(onPressed: () {}, child: Text(user['tier']))
                    ],
                  ),
                  Row(
                    children: [
                      Text('Descuento actual: ${user["discount_percentage"]}%', style: style),
                    ],
                  ),
                  Row(
                    children: [
                      Text('¡Has alcanzado el nivel mas alto!'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Has realizado ${user['total_orders']} pedidos en total.'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Nivel ${user['tier']} desbloqueado'),
                  ),
              
                ],
              ),
            )
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Datos del perfil', style: style.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Text('Nombre', style: style.copyWith(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    children: [
                      Text(userdata['first_name']),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Apellido', style: style.copyWith(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    children: [
                      Text(userdata['last_name']),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Correo', style: style.copyWith(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    children: [
                      Text(userdata['email']),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Rol', style: style.copyWith(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    children: [
                      Text(userdata['role']),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            )
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(),
          Text('Cargando...')
        ],
      );
    }
  }
}
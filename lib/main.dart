import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_registration.dart';
import 'login.dart';
import 'catalogue.dart';
import 'products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SI2 mobile',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

var selectedIndex = 0;
String token = "";
String refreshToken = "";

  void setToken(String newToken, String newRefreshToken) {
    token = newToken;
    refreshToken = newRefreshToken;
    print(token);
    print(refreshToken);
  }

  @override
  Widget build(BuildContext context) {
  Widget page;
  switch (selectedIndex) {
    case 0:
      page = UserRegistration();
    case 1:
      page = Login(setToken);
    case 2:
      page = Catalogue(token);
    case 3:
      page = Products(token);
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          bottomNavigationBar: NavigationBar(
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.app_registration),
                      label: 'Registro',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.login),
                      label: 'Login',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.list),
                      label: 'Catálogo',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.list_alt),
                      label: 'Productos',
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
          body: Row(
            children: [
              SafeArea(child: Text("")),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


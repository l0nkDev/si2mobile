import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si2mobile/screens/catalog-purchase/ar.dart';
import 'package:si2mobile/screens/chatbot/chat.dart';
import 'package:si2mobile/screens/chatbot/list.dart';
import 'package:si2mobile/screens/user/feedback.dart';
import 'package:si2mobile/screens/user/profile.dart';
import 'screens/auth-session/login.dart';
import 'screens/auth-session/register.dart';
import 'screens/catalog-purchase/cart.dart';
import 'screens/catalog-purchase/catalogue.dart';
import 'screens/catalog-purchase/product.dart';
import 'screens/user/purchases.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications();
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

var selectedIndex = 1;
var product = 0;
var user = 0;
bool isLogged = false;
late SharedPreferences prefs;
String token = "";
String chattoken = "";
String refreshToken = "";

  void setToken(String newToken) {
    token = newToken;
    isLogged = true;
    prefs.setString('token', token);
  }

  void setUser(int id) {
    user = id;
  }

  void setChat(String token) {
    chattoken = token;
  }

  void goto(int n, {int y = 0}) { setState(() { 
    print("y: $y | n: $n");
    product = y;
    selectedIndex = n; 
  }); }

  @override
  void initState() {
    initPrefs();
    super.initState();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    if (token != '') {isLogged = true;}
    setState(() {});
  }

  logout() async {
    token = ""; 
    user = 0; 
    isLogged = false;
    prefs.setString('token', '');
    selectedIndex = 1; 
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  Widget page;
  switch (selectedIndex) {
    case 0:
      page = Catalogue(isLogged: isLogged, token: token, goto: goto,);
    case 1:
      page = Login(setToken, setUser, goto);
    case 2:
      page = CartScreen(isLogged: isLogged, token: token, goto: goto);
    case 3:
      page = Purchases(isLogged: isLogged, token: token, goto: goto);
    case 4:
      page = ProductScreen(isLogged: isLogged, token: token, goto: goto, productid: product,);
    case 5:
      page = Register(setToken, goto);
    case 6: 
      page = UserFeedback(product, token);
    case 7: 
      page = ChatList(token: token, goto: goto, setchat: setChat, user: user);
    case 8: 
      page = Basic(token: token, goto: goto, user: user, chatid: product, chattoken: chattoken);
    case 9: 
      page = Profile(token);
    case 10: 
      page = DebugOptions();
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(title: const Text('FICCT e-commerce')),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.only(top: 40),
              children: [
              Column(
                children: [
                  InkWell(
                    onTap: () {setState(() {
                      if (isLogged) {
                        logout();
                      } else { selectedIndex = 1; }
                      Navigator.pop(context);
                      });},
                    child: Row(
                      children: [
                        SizedBox(height: 64, width: 10,),
                        Icon(isLogged ? Icons.logout : Icons.login),
                        SizedBox(height: 64, width: 10,),
                        Text(isLogged ? "Cerrar sesion" : "Iniciar Sesion"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {setState(() {selectedIndex = 0; Navigator.pop(context);});},
                    child: Row(
                      children: [
                        SizedBox(height: 64, width: 10,),
                        Icon(Icons.shopping_bag_outlined),
                        SizedBox(height: 64, width: 10,),
                        Text("Catalogo"),
                      ],
                    ),
                  ),
                  if (isLogged)
                    InkWell(
                      onTap: () {setState(() {selectedIndex = 3; Navigator.pop(context);});},
                      child: Row(
                        children: [
                          SizedBox(height: 64, width: 10,),
                          Icon(Icons.shopping_cart_outlined),
                          SizedBox(height: 64, width: 10,),
                          Text("Historial de compras"),
                        ],
                      ),
                    ),
                  if (isLogged)
                    InkWell(
                      onTap: () {setState(() {selectedIndex = 9; Navigator.pop(context);});},
                      child: Row(
                        children: [
                          SizedBox(height: 64, width: 10,),
                          Icon(Icons.person),
                          SizedBox(height: 64, width: 10,),
                          Text("Perfil de usuario"),
                        ],
                      ),
                    ),
                  if (isLogged)
                    InkWell(
                      onTap: () {setState(() {selectedIndex = 7; Navigator.pop(context);});},
                      child: Row(
                        children: [
                          SizedBox(height: 64, width: 10,),
                          Icon(Icons.person),
                          SizedBox(height: 64, width: 10,),
                          Text("Chatbot"),
                        ],
                      ),
                    ),
                  InkWell(
                    onTap: () {setState(() {selectedIndex = 10; Navigator.pop(context);});},
                    child: Row(
                      children: [
                        SizedBox(height: 64, width: 10,),
                        Icon(Icons.person),
                        SizedBox(height: 64, width: 10,),
                        Text("AR"),
                      ],
                    ),
                  ),
                ],
              )
              ],
            ),
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


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:parking_hub_propietarios/AuthState.dart';
import 'package:parking_hub_propietarios/screen/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _username = '';
  String _email = '';

  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;
  int _editIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String token = Provider.of<AuthState>(context, listen: false).token;
      Map<String, dynamic> decodedToken = _decodeToken(token);
      String userId = decodedToken['id'];

      final url =
          Uri.parse('https://test-2-slyp.onrender.com/api/user/$userId');
      final response = await http.get(
        url,
        headers: {'x-access-token': token},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          _name = userData['name'];
          _username = userData['username'];
          _email = userData['email'];
        });
      } else {
        print('Error al obtener los datos del usuario: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al obtener los datos del usuario: $error');
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    List<String> parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token inválido');
    }

    String payload = _decodeBase64(parts[1]);
    return jsonDecode(payload);
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Token inválido');
    }
    return utf8.decode(base64Url.decode(output));
  }

  Future<void> _updateUserData() async {
    try {
      String token = Provider.of<AuthState>(context, listen: false).token;
      Map<String, dynamic> decodedToken = _decodeToken(token);
      String userId = decodedToken['id'];

      final url =
          Uri.parse('https://test-2-slyp.onrender.com/api/user/$userId');
      final response = await http.put(
        url,
        headers: {'x-access-token': token},
        body: {
          'name': _nameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _name = _nameController.text;
          _username = _usernameController.text;
          _email = _emailController.text;
          _isEditing = false;
          _editIndex = -1;
        });
      } else {
        print('Error al actualizar los datos del usuario: ${response.statusCode}');
      }
    } catch (error) {
      print('Error al actualizar los datos del usuario: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 137, 15, 153), // Azul marino oscuro
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
              ),
              const SizedBox(height: 60),
              itemProfile('Nombre', _name, Icons.person, 0),
              const SizedBox(height: 10),
              itemProfile('Nombre de usuario', _username, Icons.account_circle, 1),
              const SizedBox(height: 10),
              itemProfile('Email', _email, Icons.mail_outline, 2),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                    launch(
                        'https://darktermsandconditions.netlify.app/privacy.html');
                },
                
                child: const Text('Términos y condiciones', style: TextStyle(fontSize: 18)),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                },
               
                child: const Text('Cerrar Sesión', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.grey.withOpacity(.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _isEditing &&
                _editIndex ==
                    index
            ? TextFormField(
                controller: title == 'Nombre'
                    ? _nameController
                    : title == 'Nombre de usuario'
                        ? _usernameController
                        : _emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: subtitle,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              )
            : Text(subtitle),
        leading: Icon(
          iconData,
          color: _isEditing && _editIndex == index ? Colors.green : Colors.black,
        ),
        trailing: _isEditing && _editIndex == index
            ? IconButton(
                onPressed: () async {
                  await _updateUserData();
                },
                icon: Icon(
                  Icons.save,
                  color: Colors.green,
                ),
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                    _editIndex = index;
                    _nameController.text = _name;
                    _usernameController.text = _username;
                    _emailController.text = _email;
                  });
                },
                icon: Icon(Icons.edit),
              ),
        tileColor: Colors.white,
      ),
    );
  }
}

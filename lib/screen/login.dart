import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_hub_propietarios/screen/NavigationBarApp.dart';
import "package:parking_hub_propietarios/AuthState.dart";
import 'package:provider/provider.dart';

import 'package:parking_hub_propietarios/screen/register.dart';
// Importa la página de inicio (homepage)

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginScreen1State createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginPage> {
  bool _isObscurePassword = true;
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  Future<void> signIn(String email, String password) async {
    final apiUrl = 'https://test-2-slyp.onrender.com/api/auth/signin';
    //final apiUrl = 'http://192.168.1.7:3000/api/auth/signin';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String token = responseData['token'];
        Provider.of<AuthState>(context, listen: false).setToken(token);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationBarApp()),
        );
      } else {
        // Credenciales inválidas, muestra un mensaje de error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Inicio de sesión fallido. Por favor, inténtelo de nuevo.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error en la solicitud HTTP: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Ocurrió un error durante el inicio de sesión. Por favor, inténtelo de nuevo más tarde.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 137, 15, 153),
                  Color.fromARGB(255, 67, 7, 75),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                '¡Hola!\nInicia sesión',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {
                          _isEmailValid = value.isNotEmpty && value.contains('@');
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: _isEmailValid
                            ? const Icon(Icons.check, color: Color.fromARGB(255, 137, 15, 153))
                            : const Icon(Icons.error, color: Colors.black),
                        labelText: 'Gmail',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: _isObscurePassword,
                      onChanged: (value) {
                        setState(() {
                          _isPasswordVisible = !_isObscurePassword;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscurePassword = !_isObscurePassword;
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: _isPasswordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xff03302d),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: () {
                        signIn(emailController.text, passwordController.text);
                      },
                      child: const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: const Color.fromARGB(255, 137, 15, 153), // Color del botón
                      ),
                    ),
                    const SizedBox(height: 150),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '¿No tienes una cuenta?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Aquí puedes implementar la navegación a la página de registro (registerpage)
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                            },
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

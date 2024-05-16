import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_hub_propietarios/screen/NavigationBarApp.dart';
import 'package:parking_hub_propietarios/screen/login.dart';
import "package:parking_hub_propietarios/AuthState.dart";

import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isObscurePassword = true;
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  bool _acceptTerms = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signUp(
      String name, String username, String email, String password) async {
    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Por favor, completa todos los campos.'),
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
    } else if (!email.contains('@')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Por favor, ingresa un correo electrónico válido.'),
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
    } else if (password != confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Las contraseñas no coinciden.'),
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
    } else if (!_acceptTerms) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Debes aceptar los términos y condiciones para registrarte.'),
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
    } else {
      final apiUrl = 'https://test-2-slyp.onrender.com/api/auth/signup';
      //final apiUrl = 'http://192.168.1.7:3000/api/auth/signup';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode({
            'name': name,
            'username': username,
            'email': email,
            'password': password,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          String token = responseData['token'];
          Provider.of<AuthState>(context, listen: false).setToken(token);

          // Registro exitoso, redirige al usuario a la página de perfil
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NavigationBarApp()),
        );
        } else {
          // Error en el registro, muestra un mensaje de error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'Registro fallido. Por favor, inténtelo de nuevo.'),
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
                'Ocurrió un error durante el registro. Por favor, inténtelo de nuevo más tarde.',
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
                  Color(0xff12baa1),
                  Color(0xff03302d),
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                '¡Hola!\nRegístrate',
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {
                          _isEmailValid =
                              value.isNotEmpty && value.contains('@');
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: _isEmailValid
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.error,
                                color: Color.fromARGB(255, 5, 5, 5)),
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
                    TextField(
                      controller: confirmPasswordController,
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
                        labelText: 'Confirmar Contraseña',
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _acceptTerms = value!;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            launch(
                                'https://darktermsandconditions.netlify.app/privacy.html');
                          },
                          child: Text(
                            'Aceptas términos y condiciones',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xff03302d),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        signUp(nameController.text, usernameController.text,
                            emailController.text, passwordController.text);
                      },
                      child: const Text(
                        'REGISTRARSE',
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
                        backgroundColor:
                            const Color(0xff12baa1), // Color del botón
                      ),
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '¿Ya tienes una cuenta?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              'Iniciar sesión',
                              style: const TextStyle(
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

import 'package:flutter/material.dart';
import 'package:parking_hub_propietarios/main/RequestsParking.dart';
import 'package:parking_hub_propietarios/screen/register.dart';
import 'login.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(WelcomeScreen());
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 0), // Ajuste de separación de 20px
                Container(
                  width: 350.0,
                  height: 350.0,
                  margin: EdgeInsets.only(left: 20), // Ajuste para centrar visualmente el GIF
                  child: Lottie.asset(
                    'assets/json/welcome.json',
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: 15), // Ajuste de separación de 15px
                Text(
                  'Bienvenido a ParkingHub',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Alquila tu garaje a tu manera y modo',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(350, 50), // Tamaño del botón igual al de los inputs
                    backgroundColor: Colors.blue, // Color del botón
                  ),
                  child: Text(
                    'Registrarse',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(350, 50), // Tamaño del botón igual al de los inputs
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Color del botón
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.blue), // Color del texto del botón
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

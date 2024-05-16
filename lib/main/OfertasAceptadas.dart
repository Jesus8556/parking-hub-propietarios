import 'package:flutter/material.dart';
import 'package:parking_hub_propietarios/socket_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:parking_hub_propietarios/AuthState.dart';

// Modelo para contraoferta
class Contraoferta {
  final String id;
  final String estado;
  final String user;
  final String metodo;
  final String? userAccept;
  final String garage;
  final double monto;
  final DateTime fechaCreacion;

  Contraoferta({
    required this.id,
    required this.estado,
    required this.user,
    required this.metodo,
    this.userAccept,
    required this.garage,
    required this.monto,
    required this.fechaCreacion,
  });

  factory Contraoferta.fromJson(Map<String, dynamic> json) {
    return Contraoferta(
      id: json['_id'],
      estado: json['estado'],
      user: json['user'],
      metodo:json["pago"],
      userAccept: json['userAccept'],
      garage: json['garage'],
      monto: json['monto'].toDouble(),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}

class OfertasAceptadas extends StatefulWidget {
  const OfertasAceptadas({Key? key}) : super(key: key);

  @override
  _OfertasAceptadasState createState() => _OfertasAceptadasState();
}

class _OfertasAceptadasState extends State<OfertasAceptadas> {
  late IO.Socket socket;
  List<Contraoferta> contraofertasAceptadas =
      []; // Lista para almacenar contraofertas aceptadas
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    socket = Provider.of<SocketService>(context, listen: false).socket;
    _setupSocketListeners(); // Configura el socket para escuchar eventos
    _fetchContraofertasAceptadas(); // Obtiene las contraofertas aceptadas iniciales
  }

  void _setupSocketListeners() {
    // Escucha el evento de contraoferta aceptada
    socket.on('contraoferta_aceptada', (data) {
      if (mounted) {
        try {
          if (data != null && data is Map<String, dynamic>) {
            final nuevaContraoferta = Contraoferta.fromJson(data['data']);
            setState(() {
              contraofertasAceptadas
                  .add(nuevaContraoferta); // Agregar a la lista
            });
          }
        } catch (e) {
          print('Error al procesar contraoferta aceptada: $e');
        }
      }
    });
  }

  Future<void> _fetchContraofertasAceptadas() async {
    String token = Provider.of<AuthState>(context, listen: false).token;
    String url =
        'https://test-2-slyp.onrender.com/api/contraoferta/aceptada'; // URL para obtener contraofertas aceptadas

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-access-token': token,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          contraofertasAceptadas = data
              .map((e) => Contraoferta.fromJson(e))
              .toList(); // Asigna la lista de contraofertas aceptadas
          isLoading = false; // Indicar que se completó la carga
        });
      } else {
        throw Exception('Error al obtener contraofertas aceptadas');
      }
    } catch (e) {
      print('Error al obtener contraofertas aceptadas: $e');
      setState(() {
        isLoading = false; // Deja de mostrar el indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Garages", style: TextStyle(color: Colors.white)),
        backgroundColor:
            const Color.fromARGB(255, 137, 15, 153), // Azul marino oscuro
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Muestra indicador de carga mientras se obtienen datos
          : ListView.builder(
              itemCount: contraofertasAceptadas
                  .length, // Número total de contraofertas aceptadas
              itemBuilder: (context, index) {
                final contraoferta = contraofertasAceptadas[
                    index]; // Obtener la contraoferta actual
                return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                          'Monto: S/${contraoferta.monto.toStringAsFixed(2)}'),
                      subtitle: Text(
                        'Estado: ${contraoferta.estado}\nMétodo de pago: ${contraoferta.metodo}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          // Puedes agregar funcionalidad para interactuar con la contraoferta
                        },
                      ),
                    ));
              },
            ),
    );
  }
}

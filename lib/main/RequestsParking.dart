import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:parking_hub_propietarios/main/OfertasAceptadas.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:provider/provider.dart';
import 'package:parking_hub_propietarios/AuthState.dart';
import 'package:parking_hub_propietarios/socket_service.dart';

// Modelo para representar las ofertas cercanas
class GarajeCercano {
  final String id;
  final String address;
  final double latitud;
  final double longitud;

  GarajeCercano({
    required this.id,
    required this.address,
    required this.latitud,
    required this.longitud,
  });

  factory GarajeCercano.fromJson(Map<String, dynamic> json) {
    return GarajeCercano(
      id: json['id'],
      address: json['address'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
    );
  }
}

class Oferta {
  final String id;
  final bool filtroAlquiler;
  final double monto;
  final String user;
  final String? name;
  final double latitud;
  final double longitud;
  final double hora;
  final DateTime createdAt;
  final List<GarajeCercano> garajesCercanos;

  Oferta({
    required this.id,
    required this.filtroAlquiler,
    required this.monto,
    required this.user,
    required this.name,
    required this.latitud,
    required this.longitud,
    required this.hora,
    required this.createdAt,
    required this.garajesCercanos,
  });

  factory Oferta.fromJson(Map<String, dynamic> json) {
    var garajesList = <GarajeCercano>[];
    if (json.containsKey('garajesCercanos') &&
        json['garajesCercanos'] != null) {
      garajesList = (json['garajesCercanos'] as List)
          .map((garaje) => GarajeCercano.fromJson(garaje))
          .toList();
    }

    return Oferta(
      id: json['_id'],
      filtroAlquiler: json['filtroAlquiler'],
      monto: json['monto'].toDouble(),
      user: json['user'],
      name: json['name'] ?? "",
      hora: json["hora"].toDouble(),
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      garajesCercanos: garajesList,
    );
  }
}

class RequestParkingPage extends StatefulWidget {
  const RequestParkingPage({Key? key}) : super(key: key);

  @override
  _RequestParkingPageState createState() => _RequestParkingPageState();
}

class _RequestParkingPageState extends State<RequestParkingPage> {
  late io.Socket socket;
  List<Oferta> ofertas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    socket = Provider.of<SocketService>(context, listen: false).socket;
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.on('nueva_oferta', (data) {
      if (mounted) {
        try {
          if (data != null && data is Map<String, dynamic>) {
            setState(() {
              ofertas.add(Oferta.fromJson(data));
            });
          } else {
            print('Datos de oferta recibidos no válidos');
          }
        } catch (e) {
          print('Error al procesar la oferta recibida: $e');
        }
      }
    });
    socket.on('oferta_eliminada', (data) {
      if (mounted) {
        try {
          if (data != null && data is Map<String, dynamic>) {
            setState(() {
              ofertas.removeWhere((oferta) =>
                  oferta.id ==
                  data['ofertaId']); // Eliminar la oferta por su ID
            });
          }
        } catch (e) {
          print('Error al procesar la oferta eliminada: $e');
        }
      }
    });
  }

  Future<List<Oferta>> fetchOfertasCercanas() async {
    String token = Provider.of<AuthState>(context, listen: false).token;
    Map<String, dynamic> decodedToken = _decodeToken(token);
    String userId = decodedToken['id'];
    String url =
        'https://test-2-slyp.onrender.com/api/oferta/oferta-cercana/$userId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-access-token': token,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => Oferta.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener ofertas cercanas');
    }
  }

  // Decodificación del token para obtener información de usuario
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

  Future<void> enviarContraoferta(
      String ofertaId, double monto, String garajeId) async {
    String token = Provider.of<AuthState>(context, listen: false).token;

    final response = await http.post(
      Uri.parse('https://test-2-slyp.onrender.com/api/contraoferta/$ofertaId'),
      headers: {
        'x-access-token': token,
        'Content-Type': 'application/json',
      },
      body:
          jsonEncode({'monto': monto, 'oferta': ofertaId, 'garage': garajeId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contraoferta enviada con éxito'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al enviar contraoferta'),
      ));
    }
  }

  Future<void> ignorarOferta(String ofertaId) async {
    String token = Provider.of<AuthState>(context, listen: false).token;

    final response = await http.post(
      Uri.parse(
          'https://test-2-slyp.onrender.com/api/oferta/ignorar/$ofertaId'),
      headers: {
        'x-access-token': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Oferta ignorada con éxito'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error al ignorar la oferta'),
      ));
    }
  }

  void mostrarDialogoContraoferta(Oferta oferta) {
    double monto = oferta.monto; // Monto inicial
    bool isTextFieldEditable = false;
    String? garajeSeleccionadoId; // ID del garaje seleccionado

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Opciones de oferta",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mensaje aclaratorio
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      "Puedes modificar el monto y seleccionar un garaje.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Campo de texto para el monto
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: monto
                                .toStringAsFixed(2), // Muestra dos decimales
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Monto',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: 'Editar monto',
                              onPressed: () {
                                setState(() {
                                  isTextFieldEditable =
                                      !isTextFieldEditable; // Alterna la editabilidad
                                });
                              },
                            ),
                          ),
                          readOnly: !isTextFieldEditable,
                          onChanged: (value) {
                            final parsedValue = double.tryParse(value);
                            if (parsedValue != null) {
                              setState(() {
                                monto = parsedValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Slider para ajustar el monto
                  Slider(
                    value: monto,
                    min: 0,
                    max: 50, // Rango del slider
                    divisions:
                        100, // Para permitir ajustes finos (0.1 incrementos)
                    label: monto.toStringAsFixed(
                        2), // Mostrar el valor con dos decimales
                    onChanged: (value) {
                      setState(() {
                        monto = value; // Actualiza el valor del slider
                      });
                    },
                  ),

                  // Lista desplegable para seleccionar un garaje
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DropdownButton<String>(
                      hint: Text("Seleccionar garaje"),
                      value: garajeSeleccionadoId,
                      onChanged: (value) {
                        setState(() {
                          garajeSeleccionadoId = value;
                        });
                      },
                      items: oferta.garajesCercanos.map((garaje) {
                        return DropdownMenuItem<String>(
                          value: garaje.id,
                          child: Text(garaje.address),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (garajeSeleccionadoId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor, selecciona un garaje"),
                    ),
                  );
                } else {
                  enviarContraoferta(oferta.id, monto,
                      garajeSeleccionadoId!); // Enviar la contraoferta
                  Navigator.pop(context); // Cerrar el diálogo
                }
              },
              child: Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ofertas cercanas", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 137, 15, 153), // Azul marino oscuro
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      body: FutureBuilder<List<Oferta>>(
        future: fetchOfertasCercanas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error.toString();
            print(error);
            return Center(child: Text('Error al cargar las ofertas'));
          } else {
            final ofertas = snapshot.data ?? [];
            if (ofertas.isEmpty) {
              // Muestra un mensaje cuando no hay ofertas disponibles
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, color: Colors.grey, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'No hay ofertas cercanas en este momento.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Vuelve a intentarlo más tarde.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: ofertas.length,
              itemBuilder: (context, index) {
                final oferta = ofertas[index];

                return Dismissible(
                  key: Key(oferta.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // Mostrar diálogo de confirmación
                    return await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Ignorar oferta'),
                          content: Text('¿Desea ignorar esta oferta?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); // No ignorar
                              },
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true); // Ignorar
                              },
                              child: Text('Sí'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    await ignorarOferta(
                        oferta.id); // Ignorar la oferta en el backend

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Oferta ignorada'),
                      ),
                    );

                    // Remover oferta de la lista visualmente
                    ofertas.removeAt(index);
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monto: S/${oferta.monto.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Tipo de oferta: ${oferta.filtroAlquiler ? "Oferta por noche" : "Oferta por hora"}',
                              ),
                              Text(
                                oferta.filtroAlquiler
                                    ? "Numero de noches: ${oferta.hora.toStringAsFixed(2)}"
                                    : "Horas de alquiler: ${oferta.hora.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Usuario: ${oferta.name}'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                tooltip: 'Opciones',
                                onPressed: () {
                                  mostrarDialogoContraoferta(oferta);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }, 
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 137, 15, 153),// Azul marino oscuro
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OfertasAceptadas()),
                  );
                },
                child: Icon(Icons.add, color: Colors.white),
                tooltip: "Crear nuevo garage",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

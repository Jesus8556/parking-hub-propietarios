import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  LocationPickerPage({required this.onLocationSelected});

  @override
  _LocationPickerPageState createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? mapController;
  LatLng? selectedPoint;
  String? selectedAddress;
  LatLng? initialPosition; // Para la posición inicial del mapa
  bool isLocationLoaded = false; // Para saber si la ubicación está cargada

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Verificar permisos al iniciar
  }
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si el permiso está denegado, mostramos el diálogo para solicitarlo
      _showLocationPermissionDialog();
    } else {
      // Si el permiso ya está otorgado, obtenemos la ubicación del usuario
      _getUserLocation();
    }
  }


   Future<void> _showLocationPermissionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permiso de Ubicación"),
          content: const Text(
              "Esta aplicación recoge datos de ubicación para habilitar las funciones de agregar coordenadas de garages a crear"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _requestLocationPermission();
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
    Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Si el usuario ha denegado permanentemente el permiso, podemos mostrar un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permiso de ubicación denegado.")),
      );
    } else {
      // Si el usuario otorga el permiso, obtenemos la ubicación del usuario
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Servicios de ubicación desactivados
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, activa la ubicación.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permiso denegado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permiso para la ubicación denegado.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permiso denegado permanentemente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permiso denegado permanentemente.")),
      );
      return;
    }

    // Obtener la posición actual
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      initialPosition = LatLng(position.latitude, position.longitude); // Posición actual
      isLocationLoaded = true; // Indicar que la ubicación se ha cargado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seleccionar Ubicación"),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLocationLoaded
                ? Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          mapController = controller;
                        },
                        initialCameraPosition: CameraPosition(
                          target: initialPosition!, // Usar la posición del usuario como punto inicial
                          zoom: 14, // Zoom inicial
                        ),
                        markers: selectedPoint != null
                            ? {
                                Marker(
                                  markerId: MarkerId("selected_point"),
                                  position: selectedPoint!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueRed,
                                  ),
                                ),
                              }
                            : {},
                        onTap: (point) async {
                          setState(() {
                            selectedPoint = point;
                          });

                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                            point.latitude,
                            point.longitude,
                          );

                          selectedAddress = placemarks.isNotEmpty
                              ? "${placemarks.first.thoroughfare}, ${placemarks.first.locality}"
                              : "Dirección desconocida";

                          _showLocationConfirmationSheet();
                        },
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(), // Mostrar un indicador de carga mientras se obtiene la ubicación
                  ),
          ),
        ],
      ),
    );
  }

  void _showLocationConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedAddress ?? "Dirección desconocida",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedPoint != null && selectedAddress != null) {
                        widget.onLocationSelected(
                          selectedPoint!.latitude,
                          selectedPoint!.longitude,
                          selectedAddress!,
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Confirmar"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

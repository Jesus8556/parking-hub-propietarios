import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:parking_hub_propietarios/screen/WelcomeScreen.dart';
import 'socket_service.dart';
import 'AuthState.dart';
void main() {
  // Inicializa OneSignal antes de ejecutar la aplicación
  WidgetsFlutterBinding.ensureInitialized();
  
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize("d9f94d6b-d05c-4268-98af-7cd5c052fe9c");

  // Habilita las notificaciones push
  OneSignal.Notifications.requestPermission(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthState()),
        ChangeNotifierProvider(create: (context) => SocketService(serverUrl: 'https://test-2-slyp.onrender.com')),
      ],
      child: MaterialApp(
        title: 'PARKING HUB',
        home: WelcomeScreen(),  // Aquí se carga la pantalla principal
      ),
    );
  }
}

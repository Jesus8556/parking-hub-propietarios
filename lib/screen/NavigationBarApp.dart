import 'package:flutter/material.dart';
import 'package:parking_hub_propietarios/main/Garage.dart';
import 'package:parking_hub_propietarios/main/RequestsParking.dart';
import 'package:parking_hub_propietarios/main/profile.dart';

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({Key? key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
          });
        },
        indicatorColor: Color(0xFF5CECCF),
        selectedIndex: currentPageIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: Text('Garage'),
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_sharp),
            label: Text('Solicitudes'),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_sharp),
            label: Text('perfil'),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        children: [
          GaragePage(), // Página de garages
          const RequestParkingPage(), // Página de solicitudes de parkeo
          const ProfileScreen(), // Página de perfil
        ],
      ),
    );
  }
}

class NavigationDestination {
  final Icon? icon;
  final Icon? selectedIcon;
  final Widget? label;

  const NavigationDestination({
    this.icon,
    this.selectedIcon,
    this.label,
  });
}

class NavigationBar extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Color? indicatorColor;

  const NavigationBar({
    Key? key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      color: colorScheme.background,
      child: Container(
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: destinations.map<Widget>((NavigationDestination destination) {
            final int index = destinations.indexOf(destination);
            final bool isSelected = index == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onDestinationSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      isSelected ? destination.selectedIcon ?? destination.icon! : destination.icon!,
                      if (destination.label != null) destination.label!,
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
  
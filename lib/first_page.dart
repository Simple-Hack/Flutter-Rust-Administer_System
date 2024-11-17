import 'package:flutter/material.dart';
import 'web_controller.dart';
import 'second_page.dart';
import 'third_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      case 2:
        page = const ChooseClassPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Colors.lightBlue[300],
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: SafeArea(
                child: NavigationRail(
                  backgroundColor: Colors.cyan[100],
                  indicatorColor: const Color.fromARGB(134, 245, 237, 18),
                  extended: constraints.maxWidth >= 500,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('主页'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('成绩'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('选课'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                  // backgroundColor: Colors.blue[50],
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedIconTheme: const IconThemeData(color: Colors.blue),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                  selectedLabelTextStyle: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.blue[50],
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

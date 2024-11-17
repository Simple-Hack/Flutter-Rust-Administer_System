import 'package:flutter/material.dart';
import 'package:my_final_web/src/rust/frb_generated.dart';
import 'package:provider/provider.dart';
import 'web_controller.dart';
import 'first_page.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyWebState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 0, 0, 0)),
          appBarTheme: const AppBarTheme(
            color: Colors.blue, // 设置 AppBar 的背景颜色
          ),
          primaryColor: Colors.white, // 设置主颜色
          scaffoldBackgroundColor: Colors.white, // 设置 Scaffold 的背景颜色
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

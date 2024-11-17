import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class MyWebState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // ↓ Add the code below.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfilePhotpbar(),
      ],
    );
  }
}

class ProfilePhotpbar extends StatelessWidget {
  const ProfilePhotpbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('lib/img/aniya.png'),
              //fit: BoxFit.cover,
            ),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 300,
              height: 150,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconTheme(
                        data: IconThemeData(size: 40), // 调整图标大小
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person),
                            Text(
                              'Anyah',
                              style: TextStyle(fontSize: 40), // 调整文本大小
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      IconTheme(
                        data: IconThemeData(size: 40), // 调整图标大小
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_city),
                            Text(
                              'SWU',
                              style: TextStyle(fontSize: 40), // 调整文本大小
                            ),
                            SizedBox(width: 10),
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
      ],
    );
  }
}

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FlutterApp',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var favorites = <WordPair>[];

  void toggleFavorites() {
    if(favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void deleteFromFavorites(WordPair pair) {
    if(favorites.contains(pair)) {
      favorites.remove(pair);
    }
    notifyListeners();
  }
  
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    Widget page;
    switch(selectedIndex) {
      case 0:
      page = GeneratorPage();
      break;
      case 1:
      page = FavoritesPage();
      break;
      default:
      throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: constraints.maxWidth >= 600,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home), 
                  label: Text('Home')
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite), 
                  label: Text('Favorites')
                )
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            )
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            )
          )
        ],
      )
    );
    });
  }
}

class GeneratorPage extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A random idea...'),
            BigCard(pair: pair),
            SizedBox(height: 10,),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LikeButton(
                  onPressed: () {
                    appState.toggleFavorites();
                    print("Favoruites: [");
                    appState.favorites.forEach(print);
                    print("]");
                  }, 
                  active: appState.favorites.contains(pair),
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    print('button pressed');
                    appState.getNext();
                  }, 
                  child: Text('Next'),
                ),
              ],
            )
          ],
        
        ),
      );
  }
}



class FavoritesPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Favorites...", 
                style: TextStyle().copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text("Your awesome list of your favorie words")
            ],
          )
        ),
        if(appState.favorites.isEmpty)
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text("No favories  show try adding them"),
          ),
        
        for(var word in appState.favorites)
          ListTile(
            title: Text(word.asLowerCase),
            leading: IconButton(
              onPressed: () {
                appState.deleteFromFavorites(word);
              }, 
              icon: Icon(
                Icons.delete,
                color: Colors.red,
                semanticLabel: 'delete icon',
              )
            )
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    
    return Card(
      color: theme.colorScheme.primary,
      child:  Padding(
        padding:  EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      )
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.active,
    required this.onPressed
  });

  final bool active;
  final Function? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed!();
      }, 
      child: Row(
          children: [ 
            Icon(
              active ? Icons.favorite : Icons.favorite_outline,
              color: Colors.red,
              size: 24,
              semanticLabel: "add to favorites",
            ),
            Text('Like')
          ]
      )
    );
  }
}
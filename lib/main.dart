import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _PREF_KEY = 'my_key';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Preferences Bug Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Shared Preferences Bug Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String? _value;
  
  _MyHomePageState() {
    _readValue();
  }
  
  void _readValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = prefs.getString(_PREF_KEY);
    });
  }
  
  void _setValueWithExceptionHandling() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    try {
      // Trying to set a string that starts with the identifier for string lists.
      // This throws a Platform Exception
      await prefs.setString(_PREF_KEY, 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu42');
    }
    catch (e) {
      debugPrint('Exception caught: ' + e.toString());
    }
    
    _readValue(); // This will read the value 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu42' from the preference cache even though it is not stored on the Android side
  }
  
  void _setValueWithoutExceptionHandling() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Trying to set a string that starts with the identifier for string lists.
    // This throws a Platform Exception
    await prefs.setString(_PREF_KEY, 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu42');
    
    _readValue(); // This will not read the value 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu42' from the preference cache
  }
  
  void _clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This demonstrates a bug in shared_preferences\nwhere values are cached,\nbut not stored on Android.\n',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              'This is the value taken from preference cache:\n',
            ),
            Text(
              '' + (_value ?? 'null') + '\n',
              style: Theme.of(context).textTheme.headline6,
            ),
            ElevatedButton(
              onPressed: _setValueWithExceptionHandling,
              child: Text('Set value with exception handling')
            ),
            ElevatedButton(
              onPressed: _setValueWithoutExceptionHandling,
              child: Text('Set value without exception handling')
            ),
            ElevatedButton(
              onPressed: _clearAll,
              child: Text('Clear dart-side cache and platform-side storage')
            ),
          ],
        ),
      ),
    );
  }
}

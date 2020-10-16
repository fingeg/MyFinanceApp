import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myfinance_app/utils/keys.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    // Check if logged in
    storage.read(key: Keys.sessionProof).then((value) {
      if (value == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return Scaffold(
      body: Text('Home'),
    );
  }
}

import 'package:flutter/material.dart';
import 'telas/tela_inicial.dart';

void main() {
  runApp(SisgeaApp());
}

class SisgeaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SISGEA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TelaInicial(usuario: '',),
    );
  }
}

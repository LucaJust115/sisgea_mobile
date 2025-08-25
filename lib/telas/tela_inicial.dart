import 'package:flutter/material.dart';

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
      ),
      home: TelaInicial(usuario: 'Gabriel'),
    );
  }
}

class TelaInicial extends StatelessWidget {
  final String usuario;

  TelaInicial({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SISGEA'),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.red,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.redAccent),
                child: Center(
                  child: Text(
                    'SISGEA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _itemMenu(Icons.schedule, 'Agendamento', context),
              _itemMenu(Icons.airplanemode_active, 'Aeronave', context),
              _itemMenu(Icons.person, 'Aluno', context),
              _itemMenu(Icons.school, 'Instrutor', context),
              _itemMenu(Icons.build, 'Manutenção', context),
              _itemMenu(Icons.book, 'Diário', context),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boa noite, $usuario! Seja bem-vindo ao SISGEA.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _cartaoFuncionalidade(Icons.schedule, 'Agendamento', Colors.redAccent),
                  _cartaoFuncionalidade(Icons.airplanemode_active, 'Aeronave', Colors.orange),
                  _cartaoFuncionalidade(Icons.person, 'Aluno', Colors.blue),
                  _cartaoFuncionalidade(Icons.school, 'Instrutor', Colors.green),
                  _cartaoFuncionalidade(Icons.build, 'Manutenção', Colors.purple),
                  _cartaoFuncionalidade(Icons.book, 'Diário', Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icone, String titulo, BuildContext contexto) {
    return ListTile(
      leading: Icon(icone, color: Colors.white),
      title: Text(titulo, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(contexto);
        ScaffoldMessenger.of(contexto).showSnackBar(
          SnackBar(content: Text('$titulo clicado')),
        );
      },
    );
  }

  Widget _cartaoFuncionalidade(IconData icone, String titulo, Color cor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cor,
      child: InkWell(
        onTap: () {
          print('$titulo clicado');
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 48, color: Colors.white),
              SizedBox(height: 10),
              Text(
                titulo,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

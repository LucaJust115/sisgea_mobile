import 'package:flutter/material.dart';
import 'tela_agendamento.dart';
import 'tela_aeronave.dart';

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
              _itemMenu(Icons.schedule, 'Agendamento', context, TelaAgendamento()),
              _itemMenu(Icons.airplanemode_active, 'Aeronave', context, TelaAeronave()),
              _itemMenu(Icons.person, 'Aluno', context, null),
              _itemMenu(Icons.school, 'Instrutor', context, null),
              _itemMenu(Icons.build, 'Manutenção', context, null),
              _itemMenu(Icons.book, 'Diário', context, null),
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
                  _cartaoFuncionalidade(
                    Icons.schedule,
                    'Agendamento',
                    Colors.redAccent,
                    context,
                    TelaAgendamento(),
                  ),
                  _cartaoFuncionalidade(
                    Icons.airplanemode_active,
                    'Aeronave',
                    Colors.orange,
                    context,
                    TelaAeronave(),
                  ),
                  _cartaoFuncionalidade(Icons.person, 'Aluno', Colors.blue, context, null),
                  _cartaoFuncionalidade(Icons.school, 'Instrutor', Colors.green, context, null),
                  _cartaoFuncionalidade(Icons.build, 'Manutenção', Colors.purple, context, null),
                  _cartaoFuncionalidade(Icons.book, 'Diário de Bordo', Colors.teal, context, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icone, String titulo, BuildContext contexto, Widget? tela) {
    return ListTile(
      leading: Icon(icone, color: Colors.white),
      title: Text(titulo, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(contexto); // fecha o drawer
        if (tela != null) {
          Navigator.push(
            contexto,
            MaterialPageRoute(builder: (context) => tela),
          );
        } else {
          ScaffoldMessenger.of(contexto).showSnackBar(
            SnackBar(content: Text('$titulo em desenvolvimento')),
          );
        }
      },
    );
  }

  Widget _cartaoFuncionalidade(IconData icone, String titulo, Color cor, BuildContext contexto, Widget? tela) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cor,
      child: InkWell(
        onTap: () {
          if (tela != null) {
            Navigator.push(
              contexto,
              MaterialPageRoute(builder: (context) => tela),
            );
          } else {
            ScaffoldMessenger.of(contexto).showSnackBar(
              SnackBar(content: Text('$titulo em desenvolvimento')),
            );
          }
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

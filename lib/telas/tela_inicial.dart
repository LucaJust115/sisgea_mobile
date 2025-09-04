import 'package:flutter/material.dart';
import 'tela_agendamento.dart';
import 'tela_aeronave.dart';
import 'tela_aluno.dart';
import 'tela_instrutor.dart';
import 'tela_manutencao.dart';
import 'tela_diario.dart';
import '../widgets/card_funcionalidade.dart';

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
              _itemMenu(Icons.person, 'Aluno', context, TelaAluno()),
              _itemMenu(Icons.school, 'Instrutor', context, TelaInstrutor()),
              _itemMenu(Icons.build, 'Manutenção', context, TelaManutencao()),
              _itemMenu(Icons.book, 'Diário de Bordo', context, TelaDiario()),
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
                  CardFuncionalidade(
                    icone: Icons.schedule,
                    titulo: 'Agendamento',
                    cor: Colors.redAccent,
                    tela: TelaAgendamento(),
                  ),
                  CardFuncionalidade(
                    icone: Icons.airplanemode_active,
                    titulo: 'Aeronave',
                    cor: Colors.orange,
                    tela: TelaAeronave(),
                  ),
                  CardFuncionalidade(
                    icone: Icons.person,
                    titulo: 'Aluno',
                    cor: Colors.blue,
                    tela: TelaAluno(),
                  ),
                  CardFuncionalidade(
                    icone: Icons.school,
                    titulo: 'Instrutor',
                    cor: Colors.green,
                    tela: TelaInstrutor(),
                  ),
                  CardFuncionalidade(
                    icone: Icons.build,
                    titulo: 'Manutenção',
                    cor: Colors.purple,
                    tela: TelaManutencao(),
                  ),
                  CardFuncionalidade(
                    icone: Icons.book,
                    titulo: 'Diário de Bordo',
                    cor: Colors.teal,
                    tela: TelaDiario(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemMenu(IconData icone, String titulo, BuildContext contexto, Widget tela) {
    return ListTile(
      leading: Icon(icone, color: Colors.white),
      title: Text(titulo, style: TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(contexto); // fecha o drawer
        Navigator.push(
          contexto,
          MaterialPageRoute(builder: (context) => tela),
        );
      },
    );
  }
}

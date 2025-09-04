import 'package:flutter/material.dart';

class TelaAluno extends StatefulWidget {
  @override
  _TelaAlunoState createState() => _TelaAlunoState();
}

class _TelaAlunoState extends State<TelaAluno> {
  // Lista de alunos simulada (futuramente será integrada à API)
  List<Map<String, dynamic>> alunos = [];

  // Campos do formulário
  String cpf = '';
  String canac = '';
  String nome = '';
  String telefone = '';
  String email = '';
  String curso = '';
  double horasCompradas = 0.0;
  double horasVoadas = 0.0;

  // Aluno em edição
  Map<String, dynamic>? edit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alunos')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: alunos.isEmpty
                  ? Center(child: Text('Nenhum aluno cadastrado'))
                  : ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return Card(
                    child: ListTile(
                      title: Text('${aluno['nome']} (${aluno['cpf']})'),
                      subtitle: Text(
                          'Curso: ${aluno['curso']} | Telefone: ${aluno['telefone']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _abrirFormularioAluno(edit: aluno),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarAluno(aluno),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioAluno(),
        child: Icon(Icons.add),
        tooltip: 'Novo Aluno',
      ),
    );
  }

  void _abrirFormularioAluno({Map<String, dynamic>? edit}) {
    if (edit != null) {
      cpf = edit['cpf'];
      canac = edit['canac'].toString();
      nome = edit['nome'];
      telefone = edit['telefone'];
      email = edit['email'];
      curso = edit['curso'];
      horasCompradas = edit['horas_compradas'];
      horasVoadas = edit['horas_voadas'];
      this.edit = edit;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(edit != null ? 'Editar Aluno' : 'Novo Aluno'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: nome,
                  decoration: InputDecoration(labelText: 'Nome'),
                  onChanged: (val) => nome = val,
                ),
                TextFormField(
                  initialValue: cpf,
                  decoration: InputDecoration(labelText: 'CPF'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => cpf = val,
                ),
                TextFormField(
                  initialValue: canac,
                  decoration: InputDecoration(labelText: 'CANAC'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => canac = val,
                ),
                TextFormField(
                  initialValue: telefone,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  onChanged: (val) => telefone = val,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(labelText: 'E-mail'),
                  onChanged: (val) => email = val,
                ),
                TextFormField(
                  initialValue: curso,
                  decoration: InputDecoration(labelText: 'Curso'),
                  onChanged: (val) => curso = val,
                ),
                TextFormField(
                  initialValue: horasCompradas.toString(),
                  decoration: InputDecoration(labelText: 'Horas Compradas'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                  horasCompradas = double.tryParse(val) ?? 0.0,
                ),
                TextFormField(
                  initialValue: horasVoadas.toString(),
                  decoration: InputDecoration(labelText: 'Horas Voadas'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                  horasVoadas = double.tryParse(val) ?? 0.0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetFormulario();
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _salvarAluno,
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _salvarAluno() {
    if (cpf.isEmpty || nome.isEmpty || curso.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    final novoAluno = {
      'cpf': cpf,
      'canac': int.tryParse(canac) ?? 0,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'curso': curso,
      'horas_compradas': horasCompradas,
      'horas_voadas': horasVoadas,
    };

    setState(() {
      if (edit != null) {
        final index = alunos.indexOf(edit!);
        if (index != -1) {
          alunos[index] = novoAluno;
        }
        this.edit = null;
      } else {
        alunos.add(novoAluno);
      }
      _resetFormulario();
    });

    Navigator.pop(context);
  }

  void _deletarAluno(Map<String, dynamic> aluno) {
    setState(() => alunos.remove(aluno));
  }

  void _resetFormulario() {
    cpf = '';
    canac = '';
    nome = '';
    telefone = '';
    email = '';
    curso = '';
    horasCompradas = 0.0;
    horasVoadas = 0.0;
    edit = null;
  }
}

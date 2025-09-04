import 'package:flutter/material.dart';

class TelaInstrutor extends StatefulWidget {
  @override
  _TelaInstrutorState createState() => _TelaInstrutorState();
}

class _TelaInstrutorState extends State<TelaInstrutor> {
  List<Map<String, dynamic>> instrutores = [];
  Map<String, dynamic>? editando;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController cpfCtrl = TextEditingController();
  final TextEditingController telefoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController canacCtrl = TextEditingController();
  final TextEditingController habilitacaoCtrl = TextEditingController();

  void _abrirFormulario({Map<String, dynamic>? instrutor}) {
    if (instrutor != null) {
      editando = instrutor;
      nomeCtrl.text = instrutor['nome'];
      cpfCtrl.text = instrutor['cpf'];
      telefoneCtrl.text = instrutor['telefone'];
      emailCtrl.text = instrutor['email'];
      canacCtrl.text = instrutor['canac'].toString();
      habilitacaoCtrl.text = instrutor['habilitacao'];
    } else {
      editando = null;
      nomeCtrl.clear();
      cpfCtrl.clear();
      telefoneCtrl.clear();
      emailCtrl.clear();
      canacCtrl.clear();
      habilitacaoCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editando == null ? 'Novo Instrutor' : 'Editar Instrutor'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nomeCtrl,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                TextFormField(
                  controller: cpfCtrl,
                  decoration: InputDecoration(labelText: 'CPF'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o CPF' : null,
                ),
                TextFormField(
                  controller: telefoneCtrl,
                  decoration: InputDecoration(labelText: 'Telefone'),
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe o email' : null,
                ),
                TextFormField(
                  controller: canacCtrl,
                  decoration: InputDecoration(labelText: 'CANAC'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: habilitacaoCtrl,
                  decoration: InputDecoration(labelText: 'Habilitação'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _salvarInstrutor();
                Navigator.pop(context);
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _salvarInstrutor() {
    final novoInstrutor = {
      'nome': nomeCtrl.text,
      'cpf': cpfCtrl.text,
      'telefone': telefoneCtrl.text,
      'email': emailCtrl.text,
      'canac': int.tryParse(canacCtrl.text) ?? 0,
      'habilitacao': habilitacaoCtrl.text,
    };

    setState(() {
      if (editando != null) {
        final index = instrutores.indexOf(editando!);
        instrutores[index] = novoInstrutor;
        editando = null;
      } else {
        instrutores.add(novoInstrutor);
      }
    });
  }

  void _deletarInstrutor(Map<String, dynamic> instrutor) {
    setState(() {
      instrutores.remove(instrutor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instrutores')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: instrutores.isEmpty
            ? Center(child: Text('Nenhum instrutor cadastrado'))
            : ListView.builder(
          itemCount: instrutores.length,
          itemBuilder: (context, index) {
            final instrutor = instrutores[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(instrutor['nome']),
                subtitle: Text(
                    'CPF: ${instrutor['cpf']} | CANAC: ${instrutor['canac']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _abrirFormulario(instrutor: instrutor),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletarInstrutor(instrutor),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: Icon(Icons.add),
      ),
    );
  }
}

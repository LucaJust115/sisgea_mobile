import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TelaInstrutor extends StatefulWidget {
  @override
  _TelaInstrutorState createState() => _TelaInstrutorState();
}

class _TelaInstrutorState extends State<TelaInstrutor> {
  List<Map<String, dynamic>> instrutores = [];
  Map<String, dynamic>? editando;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController cpfCtrl = TextEditingController();
  final TextEditingController telefoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController canacCtrl = TextEditingController();
  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();

  // Endereço
  final TextEditingController cepCtrl = TextEditingController();
  final TextEditingController logradouroCtrl = TextEditingController();
  final TextEditingController bairroCtrl = TextEditingController();
  final TextEditingController cidadeCtrl = TextEditingController();
  final TextEditingController estadoCtrl = TextEditingController();
  final TextEditingController numeroCtrl = TextEditingController();
  final TextEditingController complementoCtrl = TextEditingController();

  String habilitacaoSelecionada = 'INVA';

  // Máscaras
  var cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  var telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  var canacMaskFormatter = MaskTextInputFormatter(
    mask: '######',
    filter: {"#": RegExp(r'[0-9]')},
  );

  var cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final String apiUrl = "http://10.0.2.2:8080/api/instrutores";

  @override
  void initState() {
    super.initState();
    _carregarInstrutores();
  }

  Future<void> _carregarInstrutores() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          instrutores =
          List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      print("Erro ao carregar instrutores: $e");
    }
  }

  Future<void> _buscarCep(String cep) async {
    try {
      final response =
      await http.get(Uri.parse("https://viacep.com.br/ws/$cep/json/"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("CEP não encontrado")),
          );
          return;
        }

        setState(() {
          logradouroCtrl.text = data['logradouro'] ?? '';
          bairroCtrl.text = data['bairro'] ?? '';
          cidadeCtrl.text = data['localidade'] ?? '';
          estadoCtrl.text = data['uf'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar CEP")),
      );
    }
  }

  void _abrirFormulario({Map<String, dynamic>? instrutor}) {
    if (instrutor != null) {
      editando = instrutor;
      nomeCtrl.text = instrutor['nome'];
      cpfCtrl.text = instrutor['cpf'];
      telefoneCtrl.text = instrutor['telefone'];
      emailCtrl.text = instrutor['email'];
      canacCtrl.text = instrutor['canac'].toString();
      habilitacaoSelecionada = instrutor['habilitacao'];

      if (instrutor['usuario'] != null) {
        usuarioCtrl.text = instrutor['usuario']['usuario'] ?? '';
      }
      senhaCtrl.clear();

      if (instrutor['endereco'] != null) {
        cepCtrl.text = instrutor['endereco']['cep'] ?? '';
        logradouroCtrl.text = instrutor['endereco']['logradouro'] ?? '';
        bairroCtrl.text = instrutor['endereco']['bairro'] ?? '';
        cidadeCtrl.text = instrutor['endereco']['cidade'] ?? '';
        estadoCtrl.text = instrutor['endereco']['estado'] ?? '';
        numeroCtrl.text = instrutor['endereco']['numero'] ?? '';
        complementoCtrl.text = instrutor['endereco']['complemento'] ?? '';
      }
    } else {
      editando = null;
      nomeCtrl.clear();
      cpfCtrl.clear();
      telefoneCtrl.clear();
      emailCtrl.clear();
      canacCtrl.clear();
      usuarioCtrl.clear();
      senhaCtrl.clear();
      cepCtrl.clear();
      logradouroCtrl.clear();
      bairroCtrl.clear();
      cidadeCtrl.clear();
      estadoCtrl.clear();
      numeroCtrl.clear();
      complementoCtrl.clear();
      habilitacaoSelecionada = 'INVA';
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
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o nome' : null,
                ),
                TextFormField(
                  controller: cpfCtrl,
                  decoration: InputDecoration(labelText: 'CPF'),
                  inputFormatters: [cpfMaskFormatter],
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe o CPF' : null,
                ),
                TextFormField(
                  controller: telefoneCtrl,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  inputFormatters: [telefoneMaskFormatter],
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: canacCtrl,
                  decoration: InputDecoration(labelText: 'CANAC'),
                  inputFormatters: [canacMaskFormatter],
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: habilitacaoSelecionada,
                  items: ['INVA', 'PLA', 'PC']
                      .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      habilitacaoSelecionada = val!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Habilitação'),
                ),
                Divider(),
                TextFormField(
                  controller: usuarioCtrl,
                  decoration: InputDecoration(labelText: 'Usuário'),
                ),
                TextFormField(
                  controller: senhaCtrl,
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                Divider(),
                TextFormField(
                  controller: cepCtrl,
                  decoration: InputDecoration(labelText: 'CEP'),
                  inputFormatters: [cepMaskFormatter],
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final cepNumerico =
                    val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cepNumerico.length == 8) {
                      _buscarCep(cepNumerico);
                    }
                  },
                ),
                TextFormField(
                  controller: logradouroCtrl,
                  decoration: InputDecoration(labelText: 'Logradouro'),
                ),
                TextFormField(
                  controller: bairroCtrl,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextFormField(
                  controller: cidadeCtrl,
                  decoration: InputDecoration(labelText: 'Cidade'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: estadoCtrl,
                  decoration: InputDecoration(labelText: 'Estado'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: numeroCtrl,
                  decoration: InputDecoration(labelText: 'Número'),
                ),
                TextFormField(
                  controller: complementoCtrl,
                  decoration: InputDecoration(labelText: 'Complemento'),
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
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarInstrutor() async {
    final instrutor = {
      "cpf": cpfCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
      "nome": nomeCtrl.text,
      "telefone": telefoneCtrl.text,
      "email": emailCtrl.text,
      "canac": int.tryParse(canacCtrl.text),
      "habilitacao": habilitacaoSelecionada,
      "usuario": {
        "usuario": usuarioCtrl.text,
        "senha": senhaCtrl.text,
        "permissao": 0
      },
      "endereco": {
        "cep": cepCtrl.text,
        "logradouro": logradouroCtrl.text,
        "bairro": bairroCtrl.text,
        "cidade": cidadeCtrl.text,
        "estado": estadoCtrl.text,
        "numero": numeroCtrl.text,
        "complemento": complementoCtrl.text,
      }
    };

    try {
      http.Response response;
      if (editando != null) {
        response = await http.put(
          Uri.parse("$apiUrl/${instrutor['cpf']}"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(instrutor),
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(instrutor),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        _carregarInstrutores();
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? "Erro ao salvar instrutor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão")),
      );
    }
  }

  Future<void> _deletarInstrutor(String cpf) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/$cpf"));
      if (response.statusCode == 200) {
        _carregarInstrutores();
      }
    } catch (e) {
      print("Erro ao deletar: $e");
    }
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
                    'CPF: ${instrutor['cpf']} | CANAC: ${instrutor['canac']} | Usuário: ${instrutor['usuario']?['usuario'] ?? ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _abrirFormulario(instrutor: instrutor),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deletarInstrutor(instrutor['cpf']),
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

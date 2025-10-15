import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisgea_mobile/config.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TelaAluno extends StatefulWidget {
  @override
  _TelaAlunoState createState() => _TelaAlunoState();
}

class _TelaAlunoState extends State<TelaAluno> {
  final String apiUrl = AppConfig.apiUrl + "/api/alunos";
  List<Map<String, dynamic>> alunos = [];
  Map<String, dynamic>? edit;
  bool carregando = true;

  // Controllers
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _canacController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cursoController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _horasCompradasController = TextEditingController();
  final _horasVoadasController = TextEditingController();

  // Máscaras
  final cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final canacMaskFormatter = MaskTextInputFormatter(
    mask: '######',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final List<String> cursosDisponiveis = [
    'Piloto Privado',
    'Piloto Comercial',
    'Piloto Comercial / IFR',
    'Instrutor de Voo',
    'IFR',
  ];

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  Future<void> _carregarAlunos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          alunos = data.map((a) => a as Map<String, dynamic>).toList();
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
      }
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<void> _buscarEnderecoPorCep(String cep) async {
    if (cep.length != 8) return;
    try {
      final response =
      await http.get(Uri.parse("https://viacep.com.br/ws/$cep/json/"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["erro"] == null) {
          setState(() {
            _logradouroController.text = data["logradouro"] ?? '';
            _bairroController.text = data["bairro"] ?? '';
            _cidadeController.text = data["localidade"] ?? '';
            _estadoController.text = data["uf"] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar CEP: $e");
    }
  }

  Future<bool> _cpfOuCanacJaExiste(String campo, String valor) async {
    try {
      final response = await http.get(Uri.parse("$apiUrl?$campo=$valor"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Erro ao verificar duplicidade: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alunos')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: carregando
                  ? Center(child: CircularProgressIndicator())
                  : alunos.isEmpty
                  ? Center(child: Text('Nenhum aluno cadastrado'))
                  : ListView.builder(
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          '${aluno['nome']} (${_formatCpf(aluno['cpf'])})'),
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

  String _formatCpf(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  void _abrirFormularioAluno({Map<String, dynamic>? edit}) {
    if (edit != null) {
      _cpfController.text = edit['cpf'] ?? '';
      _canacController.text = edit['canac']?.toString() ?? '';
      _nomeController.text = edit['nome'] ?? '';
      _telefoneController.text = edit['telefone'] ?? '';
      _emailController.text = edit['email'] ?? '';
      _cursoController.text = edit['curso'] ?? '';

      _cepController.text = edit['cep'] ?? '';
      _logradouroController.text = edit['logradouro'] ?? '';
      _numeroController.text = edit['numero'] ?? '';
      _complementoController.text = edit['complemento'] ?? '';
      _bairroController.text = edit['bairro'] ?? '';
      _cidadeController.text = edit['cidade'] ?? '';
      _estadoController.text = edit['estado'] ?? '';

      _horasCompradasController.text =
          (edit['horas_compradas'] as num?)?.toString() ?? '';
      _horasVoadasController.text =
          (edit['horas_voadas'] as num?)?.toString() ?? '';

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
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'CPF'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfMaskFormatter],
                  controller: _cpfController,
                  enabled: edit == null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'CANAC'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [canacMaskFormatter],
                  controller: _canacController,
                  enabled: edit == null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [telefoneMaskFormatter],
                  controller: _telefoneController,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                ),
                DropdownButtonFormField<String>(
                  value: _cursoController.text.isNotEmpty
                      ? _cursoController.text
                      : null,
                  decoration: InputDecoration(labelText: 'Curso'),
                  items: cursosDisponiveis.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => _cursoController.text = val ?? '',
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'CEP'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [cepMaskFormatter],
                  controller: _cepController,
                  onChanged: (val) {
                    final rawCep =
                    cepMaskFormatter.getUnmaskedText(); // só números
                    if (rawCep.length == 8) _buscarEnderecoPorCep(rawCep);
                  },
                ),
                TextFormField(
                  controller: _cidadeController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                  enabled: false,
                ),
                TextFormField(
                  controller: _estadoController,
                  decoration: InputDecoration(labelText: 'Estado'),
                  enabled: false,
                ),
                TextFormField(
                  controller: _logradouroController,
                  decoration: InputDecoration(labelText: 'Logradouro'),
                ),
                TextFormField(
                  controller: _bairroController,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextFormField(
                  controller: _numeroController,
                  decoration: InputDecoration(labelText: 'Número'),
                ),
                TextFormField(
                  controller: _complementoController,
                  decoration: InputDecoration(labelText: 'Complemento'),
                ),
                TextFormField(
                  controller: _horasCompradasController,
                  decoration: InputDecoration(labelText: 'Horas Compradas'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _horasVoadasController,
                  decoration: InputDecoration(labelText: 'Horas Voadas'),
                  keyboardType: TextInputType.number,
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

  Future<void> _salvarAluno() async {
    final alunoData = {
      'cpf': _cpfController.text,
      'canac': int.tryParse(_canacController.text) ?? 0,
      'nome': _nomeController.text,
      'telefone': _telefoneController.text,
      'email': _emailController.text,
      'curso': _cursoController.text,
      'cep': _cepController.text,
      'logradouro': _logradouroController.text,
      'numero': _numeroController.text,
      'complemento': _complementoController.text,
      'bairro': _bairroController.text,
      'cidade': _cidadeController.text,
      'estado': _estadoController.text,
      'horas_compradas':
      double.tryParse(_horasCompradasController.text) ?? 0.0,
      'horas_voadas': double.tryParse(_horasVoadasController.text) ?? 0.0,
    };

    try {
      http.Response response;

      if (edit != null) {
        response = await http.put(
          Uri.parse('$apiUrl/${_cpfController.text}'),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(alunoData)),
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(alunoData)),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _carregarAlunos();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(edit != null
                  ? 'Aluno atualizado com sucesso!'
                  : 'Aluno salvo com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar/atualizar aluno')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na conexão com API: $e')),
      );
    }
  }

  Future<void> _deletarAluno(Map<String, dynamic> aluno) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/${aluno['cpf']}'),
      );

      if (response.statusCode == 200) {
        _carregarAlunos();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno deletado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar aluno')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na conexão com API: $e')),
      );
    }
  }

  void _resetFormulario() {
    _cpfController.clear();
    _canacController.clear();
    _nomeController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _cursoController.clear();
    _cepController.clear();
    _logradouroController.clear();
    _numeroController.clear();
    _complementoController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _estadoController.clear();
    _horasCompradasController.clear();
    _horasVoadasController.clear();
    edit = null;
  }
}

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
  String cpf = '';
  String canac = '';
  String nome = '';
  String telefone = '';
  String email = '';
  String curso = '';
  double horasCompradas = 0.0;
  double horasVoadas = 0.0;
  Map<String, dynamic>? edit;
  bool carregando = true;

  final cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final List<String> cursosDisponiveis = [
    'Piloto Privado',
    'Piloto Comercial',
    'Piloto Comercial / IFR',
    'Instrutor de Voo',
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
        debugPrint(
            'Erro ao carregar alunos: status ${response.statusCode}, body: ${response.body}');
        setState(() => carregando = false);
      }
    } catch (e) {
      debugPrint('Exceção ao carregar alunos: $e');
      setState(() => carregando = false);
    }
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
                            icon:
                            Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _abrirFormularioAluno(edit: aluno),
                          ),
                          IconButton(
                            icon:
                            Icon(Icons.delete, color: Colors.red),
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
      cpf = edit['cpf'] ?? '';
      cpfMaskFormatter.formatEditUpdate(
          TextEditingValue(), TextEditingValue(text: cpf));
      canac = edit['canac']?.toString() ?? '';
      nome = edit['nome'] ?? '';
      telefone = edit['telefone'] ?? '';
      email = edit['email'] ?? '';
      curso = edit['curso'] ?? '';
      horasCompradas =
          (edit['horas_compradas'] as num?)?.toDouble() ?? 0.0;
      horasVoadas = (edit['horas_voadas'] as num?)?.toDouble() ?? 0.0;
      this.edit = edit;
    } else {
      cpfMaskFormatter.clear();
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
                  decoration: InputDecoration(labelText: 'CPF'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfMaskFormatter],
                  controller: TextEditingController(
                      text: cpfMaskFormatter.maskText(cpf)),
                  onChanged: (val) {
                    cpf = cpfMaskFormatter.getUnmaskedText();
                  },
                  enabled: edit == null,
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
                DropdownButtonFormField<String>(
                  value: curso.isNotEmpty ? curso : null,
                  decoration: InputDecoration(labelText: 'Curso'),
                  items: cursosDisponiveis.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      curso = val ?? '';
                    });
                  },
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

  Future<void> _salvarAluno() async {
    if (cpf.isEmpty || nome.isEmpty || curso.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha os campos obrigatórios')),
      );
      return;
    }

    final alunoData = {
      'cpf': cpf,
      'canac': int.tryParse(canac) ?? 0,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'curso': curso,
      'horas_compradas': horasCompradas,
      'horas_voadas': horasVoadas,
    };

    try {
      http.Response response;

      if (edit != null) {
        response = await http.put(
          Uri.parse('$apiUrl/$cpf'),
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
        debugPrint(
            'Erro ao salvar/atualizar aluno: status ${response.statusCode}, body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao salvar/atualizar aluno (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exceção ao salvar/atualizar aluno: $e');
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
        debugPrint(
            'Erro ao deletar aluno: status ${response.statusCode}, body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao deletar aluno (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exceção ao deletar aluno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na conexão com API: $e')),
      );
    }
  }

  void _resetFormulario() {
    cpf = '';
    cpfMaskFormatter.clear();
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisgea_mobile/config.dart';

class TelaDiario extends StatefulWidget {
  const TelaDiario({Key? key}) : super(key: key);

  @override
  _TelaDiarioState createState() => _TelaDiarioState();
}

class _TelaDiarioState extends State<TelaDiario> {
  final String apiUrl = AppConfig.apiUrl + "/api/diarios";
  List<Map<String, dynamic>> diarios = [];
  Map<String, dynamic>? edit;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController aeronaveController = TextEditingController();
  final TextEditingController nroDiarioController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  final TextEditingController funcaoAlunoController = TextEditingController();
  final TextEditingController funcaoInstrutorController = TextEditingController();
  final TextEditingController horaAeronaveController = TextEditingController();
  final TextEditingController dataDecolagemController = TextEditingController();
  final TextEditingController dataPousoController = TextEditingController();
  final TextEditingController localDecolagemController = TextEditingController();
  final TextEditingController localPousoController = TextEditingController();
  final TextEditingController dataCorteController = TextEditingController();
  final TextEditingController horasDiuController = TextEditingController();
  final TextEditingController horasNotController = TextEditingController();
  final TextEditingController horasVfrController = TextEditingController();
  final TextEditingController horasIfrController = TextEditingController();
  final TextEditingController horasIfrCController = TextEditingController();
  final TextEditingController combustivelController = TextEditingController();
  final TextEditingController ciclosController = TextEditingController();
  final TextEditingController pobController = TextEditingController();
  final TextEditingController cargaController = TextEditingController();
  final TextEditingController natController = TextEditingController();
  final TextEditingController ocorrenciasController = TextEditingController();

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDiarios();
  }

  Future<void> _carregarDiarios() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          diarios = data.map((d) => d as Map<String, dynamic>).toList();
          carregando = false;
        });
      } else {
        debugPrint('Erro ao carregar diários: ${response.statusCode}');
        setState(() => carregando = false);
      }
    } catch (e) {
      debugPrint('Exceção ao carregar diários: $e');
      setState(() => carregando = false);
    }
  }

  Future<void> _salvarDiario() async {
    if (!_formKey.currentState!.validate()) return;

    final diarioData = {
      'aeronave': aeronaveController.text,
      'nroDiario': nroDiarioController.text,
      'data': dataController.text,
      'funcaoAluno': funcaoAlunoController.text,
      'funcaoInstrutor': funcaoInstrutorController.text,
      'horaAeronave': horaAeronaveController.text,
      'dataDecolagem': dataDecolagemController.text,
      'dataPouso': dataPousoController.text,
      'localDecolagem': localDecolagemController.text,
      'localPouso': localPousoController.text,
      'dataCorte': dataCorteController.text,
      'horasDiu': horasDiuController.text,
      'horasNot': horasNotController.text,
      'horasVfr': horasVfrController.text,
      'horasIfr': horasIfrController.text,
      'horasIfrC': horasIfrCController.text,
      'combustivel': combustivelController.text,
      'ciclos': ciclosController.text,
      'pob': pobController.text,
      'carga': cargaController.text,
      'nat': natController.text,
      'ocorrencias': ocorrenciasController.text,
    };

    try {
      http.Response response;
      if (edit != null) {
        response = await http.put(
          Uri.parse('$apiUrl/${edit!['nroDiario']}'),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(diarioData)),
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(diarioData)),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _carregarDiarios();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(edit != null ? 'Diário atualizado!' : 'Diário salvo!')),
        );
      } else {
        debugPrint('Erro ao salvar diário: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar diário (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exceção ao salvar diário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na conexão com API: $e')),
      );
    }
  }

  Future<void> _deletarDiario(Map<String, dynamic> diario) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/${diario['nroDiario']}'));
      if (response.statusCode == 200) {
        _carregarDiarios();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diário deletado com sucesso!')),
        );
      } else {
        debugPrint('Erro ao deletar diário: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar diário (status ${response.statusCode})')),
        );
      }
    } catch (e) {
      debugPrint('Exceção ao deletar diário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha na conexão com API: $e')),
      );
    }
  }

  void _resetFormulario() {
    aeronaveController.clear();
    nroDiarioController.clear();
    dataController.clear();
    funcaoAlunoController.clear();
    funcaoInstrutorController.clear();
    horaAeronaveController.clear();
    dataDecolagemController.clear();
    dataPousoController.clear();
    localDecolagemController.clear();
    localPousoController.clear();
    dataCorteController.clear();
    horasDiuController.clear();
    horasNotController.clear();
    horasVfrController.clear();
    horasIfrController.clear();
    horasIfrCController.clear();
    combustivelController.clear();
    ciclosController.clear();
    pobController.clear();
    cargaController.clear();
    natController.clear();
    ocorrenciasController.clear();
    edit = null;
  }

  void _abrirFormularioDiario({Map<String, dynamic>? diario}) {
    if (diario != null) {
      aeronaveController.text = diario['aeronave'] ?? '';
      nroDiarioController.text = diario['nroDiario'] ?? '';
      dataController.text = diario['data'] ?? '';
      funcaoAlunoController.text = diario['funcaoAluno'] ?? '';
      funcaoInstrutorController.text = diario['funcaoInstrutor'] ?? '';
      horaAeronaveController.text = diario['horaAeronave'] ?? '';
      dataDecolagemController.text = diario['dataDecolagem'] ?? '';
      dataPousoController.text = diario['dataPouso'] ?? '';
      localDecolagemController.text = diario['localDecolagem'] ?? '';
      localPousoController.text = diario['localPouso'] ?? '';
      dataCorteController.text = diario['dataCorte'] ?? '';
      horasDiuController.text = diario['horasDiu'] ?? '';
      horasNotController.text = diario['horasNot'] ?? '';
      horasVfrController.text = diario['horasVfr'] ?? '';
      horasIfrController.text = diario['horasIfr'] ?? '';
      horasIfrCController.text = diario['horasIfrC'] ?? '';
      combustivelController.text = diario['combustivel'] ?? '';
      ciclosController.text = diario['ciclos'] ?? '';
      pobController.text = diario['pob'] ?? '';
      cargaController.text = diario['carga'] ?? '';
      natController.text = diario['nat'] ?? '';
      ocorrenciasController.text = diario['ocorrencias'] ?? '';
      edit = diario;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(diario != null ? 'Editar Diário' : 'Novo Diário'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildTextField(aeronaveController, 'Aeronave'),
                  buildTextField(nroDiarioController, 'Número do Diário', keyboardType: TextInputType.number),
                  buildTextField(dataController, 'Data'),
                  buildTextField(funcaoAlunoController, 'Função do Aluno'),
                  buildTextField(funcaoInstrutorController, 'Função do Instrutor'),
                  buildTextField(horaAeronaveController, 'Hora Aeronave', keyboardType: TextInputType.number),
                  buildTextField(dataDecolagemController, 'Data Decolagem'),
                  buildTextField(dataPousoController, 'Data Pouso'),
                  buildTextField(localDecolagemController, 'Local Decolagem'),
                  buildTextField(localPousoController, 'Local Pouso'),
                  buildTextField(dataCorteController, 'Data Corte'),
                  buildTextField(horasDiuController, 'Horas Diurnas', keyboardType: TextInputType.number),
                  buildTextField(horasNotController, 'Horas Noturnas', keyboardType: TextInputType.number),
                  buildTextField(horasVfrController, 'Horas VFR', keyboardType: TextInputType.number),
                  buildTextField(horasIfrController, 'Horas IFR', keyboardType: TextInputType.number),
                  buildTextField(horasIfrCController, 'Horas IFR C', keyboardType: TextInputType.number),
                  buildTextField(combustivelController, 'Combustível Utilizado', keyboardType: TextInputType.number),
                  buildTextField(ciclosController, 'Ciclos', keyboardType: TextInputType.number),
                  buildTextField(pobController, 'POB', keyboardType: TextInputType.number),
                  buildTextField(cargaController, 'Carga', keyboardType: TextInputType.number),
                  buildTextField(natController, 'NAT'),
                  buildTextField(ocorrenciasController, 'Ocorrências', maxLines: 4),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetFormulario();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _salvarDiario,
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label é obrigatório';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    aeronaveController.dispose();
    nroDiarioController.dispose();
    dataController.dispose();
    funcaoAlunoController.dispose();
    funcaoInstrutorController.dispose();
    horaAeronaveController.dispose();
    dataDecolagemController.dispose();
    dataPousoController.dispose();
    localDecolagemController.dispose();
    localPousoController.dispose();
    dataCorteController.dispose();
    horasDiuController.dispose();
    horasNotController.dispose();
    horasVfrController.dispose();
    horasIfrController.dispose();
    horasIfrCController.dispose();
    combustivelController.dispose();
    ciclosController.dispose();
    pobController.dispose();
    cargaController.dispose();
    natController.dispose();
    ocorrenciasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diário de Bordo')),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diarios.length,
        itemBuilder: (context, index) {
          final diario = diarios[index];
          return Card(
            child: ListTile(
              title: Text('${diario['nroDiario']} - ${diario['aeronave']}'),
              subtitle: Text('Data: ${diario['data']} | Aluno: ${diario['funcaoAluno']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _abrirFormularioDiario(diario: diario),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarDiario(diario),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioDiario(),
        child: const Icon(Icons.add),
        tooltip: 'Novo Diário',
      ),
    );
  }
}

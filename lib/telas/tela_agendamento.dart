import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisgea_mobile/config.dart';

class TelaAgendamento extends StatefulWidget {
  @override
  _TelaAgendamentoState createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  final String apiUrl = AppConfig.apiUrl + "/api/agendamentos";

  Map<String, dynamic> mapAlunos = {};
  Map<String, dynamic> mapInstrutores = {};
  Map<String, dynamic> mapAeronaves = {};

  String? alunoSelecionado;
  String? instrutorSelecionado;
  String? aeronaveSelecionada;
  String partida = '';
  String destino = '';
  String tipoVoo = 'VFR-D';
  DateTime? dataAgendamento;
  TimeOfDay? horarioAgendamento;
  String status = 'Agendado';

  List<Map<String, dynamic>> agendamentos = [];
  Map<String, dynamic>? edit;

  bool carregandoListas = true;

  @override
  void initState() {
    super.initState();
    _carregarListas().then((_) => _carregarAgendamentos());
  }

  Future<void> _carregarAgendamentos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() => agendamentos = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      print('Erro ao carregar agendamentos: $e');
    }
  }

  Future<void> _carregarListas() async {
    try {
      // Alunos
      final alunosResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/alunos"));
      if (alunosResp.statusCode == 200) {
        final List data = jsonDecode(alunosResp.body);
        mapAlunos = {
          for (var a in data) a['nome']: a['cpf'] ?? a['id'] ?? a['nome']
        };
        print('Alunos carregados: ${mapAlunos.length}');
      }

      // Instrutores
      final instrutoresResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/instrutores"));
      if (instrutoresResp.statusCode == 200) {
        final List data = jsonDecode(instrutoresResp.body);
        mapInstrutores = {
          for (var i in data) i['nome']: i['cpf'] ?? i['nome']
        };
        print('Instrutores carregados: ${mapInstrutores.length}');
      }

      // Aeronaves
      final aeronavesResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/aeronaves"));
      if (aeronavesResp.statusCode == 200) {
        final List data = jsonDecode(aeronavesResp.body);
        mapAeronaves = {
          for (var a in data) a['matricula']: a['matricula'] ?? a['id']
        };
        print('Aeronaves carregadas: ${mapAeronaves.length}');
      }

      setState(() => carregandoListas = false);
    } catch (e) {
      print('Erro ao carregar listas: $e');
      setState(() => carregandoListas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendamentos')),
      body: carregandoListas
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: agendamentos.isEmpty
            ? Center(child: Text('Nenhum agendamento cadastrado'))
            : ListView.builder(
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final ag = agendamentos[index];
            return Card(
              child: ListTile(
                title: Text(
                    '${ag['aeronave']?['matricula'] ?? '---'} - ${ag['aluno']?['nome'] ?? '---'}'),
                subtitle: Text(
                    'Instrutor: ${ag['instrutor']?['nome'] ?? '---'} | Data: ${ag['data'] ?? '---'} | Status: ${ag['status'] ?? '---'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _abrirFormularioAgendamento(edit: ag),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletarAgendamento(ag),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioAgendamento(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _abrirFormularioAgendamento({Map<String, dynamic>? edit}) {
    if (edit != null) {
      try {
        aeronaveSelecionada = edit['aeronave']?['matricula']?.toString();
        alunoSelecionado = edit['aluno']?['nome']?.toString();
        instrutorSelecionado = edit['instrutor']?['nome']?.toString();
        partida = (edit['origem'] ?? edit['partida'] ?? '').toString();
        destino = (edit['destino'] ?? '').toString();
        tipoVoo = (edit['tipo_voo'] ?? edit['tipoVoo'] ?? 'VFR-D').toString();
        status = (edit['status'] ?? 'Agendado').toString();

        // Verifica e converte a data, protegendo contra null ou formato inesperado
        if (edit['data'] != null && edit['data'].toString().isNotEmpty) {
          try {
            DateTime dt = DateTime.parse(edit['data'].toString());
            dataAgendamento = DateTime(dt.year, dt.month, dt.day);
            horarioAgendamento = TimeOfDay(hour: dt.hour, minute: dt.minute);
          } catch (_) {
            dataAgendamento = null;
            horarioAgendamento = null;
          }
        }

        this.edit = edit;
      } catch (e) {
        print('Erro ao carregar dados para edição: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(edit != null ? 'Editar Agendamento' : 'Novo Agendamento'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Aeronave'),
                  items: mapAeronaves.keys
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  value: mapAeronaves.keys.contains(aeronaveSelecionada)
                      ? aeronaveSelecionada
                      : null,
                  onChanged: (val) => setState(() => aeronaveSelecionada = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Aluno'),
                  items: mapAlunos.keys
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  value: mapAlunos.keys.contains(alunoSelecionado)
                      ? alunoSelecionado
                      : null,
                  onChanged: (val) => setState(() => alunoSelecionado = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Instrutor'),
                  items: mapInstrutores.keys
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  value: mapInstrutores.keys.contains(instrutorSelecionado)
                      ? instrutorSelecionado
                      : null,
                  onChanged: (val) => setState(() => instrutorSelecionado = val),
                ),
                TextFormField(
                  initialValue: partida,
                  decoration: InputDecoration(labelText: 'Origem'),
                  onChanged: (val) => partida = val,
                ),
                TextFormField(
                  initialValue: destino,
                  decoration: InputDecoration(labelText: 'Destino'),
                  onChanged: (val) => destino = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Tipo de Voo'),
                  items: ['VFR-D', 'VFR-N', 'IFR']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: tipoVoo,
                  onChanged: (val) => setState(() => tipoVoo = val ?? 'VFR-D'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selecionarData,
                  child: Text(dataAgendamento == null
                      ? 'Selecionar Data'
                      : '${dataAgendamento!.year}-${_twoDigits(dataAgendamento!.month)}-${_twoDigits(dataAgendamento!.day)}'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _selecionarHorario,
                  child: Text(horarioAgendamento == null
                      ? 'Selecionar Horário'
                      : '${_twoDigits(horarioAgendamento!.hour)}:${_twoDigits(horarioAgendamento!.minute)}'),
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
              onPressed: _salvarAgendamento,
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _salvarAgendamento() async {
    if (aeronaveSelecionada == null ||
        alunoSelecionado == null ||
        instrutorSelecionado == null ||
        partida.isEmpty ||
        destino.isEmpty ||
        dataAgendamento == null ||
        horarioAgendamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    // Constrói a data completa e converte para UTC ISO8601
    final dataCompleta = DateTime(
      dataAgendamento!.year,
      dataAgendamento!.month,
      dataAgendamento!.day,
      horarioAgendamento!.hour,
      horarioAgendamento!.minute,
    );

    final novoAgendamento = {
      "aeronave": {"matricula": mapAeronaves[aeronaveSelecionada]},
      "aluno": {"cpf": mapAlunos[alunoSelecionado]},
      "instrutor": {"cpf": mapInstrutores[instrutorSelecionado]},
      "partida": partida,
      "destino": destino,
      "tipo_voo": tipoVoo,
      "status": status,
      "horario_partida": dataCompleta.toUtc().toIso8601String(),
      "horario_retorno":
      dataCompleta.add(Duration(hours: 1)).toUtc().toIso8601String(),
    };

    print("JSON ENVIADO:");
    print(jsonEncode(novoAgendamento));

    try {
      http.Response response;
      if (edit != null && edit!['id'] != null) {
        response = await http.put(
          Uri.parse('$apiUrl/${edit!['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(novoAgendamento),
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(novoAgendamento),
        );
      }

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        _resetFormulario();
        _carregarAgendamentos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar agendamento')),
        );
      }
    } catch (e) {
      print('Erro ao salvar agendamento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar agendamento')),
      );
    }
  }

  Future<void> _deletarAgendamento(Map<String, dynamic> ag) async {
    if (ag['id'] == null) return;
    try {
      final response = await http.delete(Uri.parse('$apiUrl/${ag['id']}'));
      if (response.statusCode == 200) {
        setState(() => agendamentos.remove(ag));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar agendamento')),
        );
      }
    } catch (e) {
      print('Erro ao deletar agendamento: $e');
    }
  }

  void _resetFormulario() {
    aeronaveSelecionada = null;
    alunoSelecionado = null;
    instrutorSelecionado = null;
    partida = '';
    destino = '';
    tipoVoo = 'VFR-D';
    dataAgendamento = null;
    horarioAgendamento = null;
    status = 'Agendado';
    edit = null;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataAgendamento = data);
  }

  void _selecionarHorario() async {
    TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data:
          MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (horario != null) setState(() => horarioAgendamento = horario);
  }
}

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

  String? aeronaveSelecionada;
  String? alunoSelecionado;
  String? instrutorSelecionado;
  String partida = '';
  String destino = '';
  String tipoVoo = 'Regular';
  DateTime? dataAgendamento;
  TimeOfDay? horarioAgendamento;
  String status = 'Pendente';

  List<String> aeronaves = [];
  List<String> alunos = [];
  List<String> instrutores = [];

  List<Map<String, dynamic>> agendamentos = [];
  Map<String, dynamic>? edit;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
    _carregarListas();
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
      final alunosResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/alunos"));
      if (alunosResp.statusCode == 200) {
        final List data = jsonDecode(alunosResp.body);
        setState(() => alunos = List<String>.from(data.map((a) => a['nome'])));
      }

      final aeronavesResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/aeronaves"));
      if (aeronavesResp.statusCode == 200) {
        final List data = jsonDecode(aeronavesResp.body);
        setState(
                () => aeronaves = List<String>.from(data.map((a) => a['matricula'])));
      }

      final instrutoresResp =
      await http.get(Uri.parse(AppConfig.apiUrl + "/api/instrutores"));
      if (instrutoresResp.statusCode == 200) {
        final List data = jsonDecode(instrutoresResp.body);
        setState(() =>
        instrutores = List<String>.from(data.map((i) => i['nome'])));
      }
    } catch (e) {
      print('Erro ao carregar listas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendamentos')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: agendamentos.isEmpty
            ? Center(
          child: Text(
            'Nenhum agendamento cadastrado',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: agendamentos.length,
          itemBuilder: (context, index) {
            final ag = agendamentos[index];
            return Card(
              child: ListTile(
                title: Text('${ag['aeronave']} - ${ag['aluno']}'),
                subtitle: Text(
                    'Instrutor: ${ag['instrutor']} | Data: ${ag['data']} | Status: ${ag['status']}'),
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
        tooltip: 'Novo Agendamento',
      ),
    );
  }

  void _abrirFormularioAgendamento({Map<String, dynamic>? edit}) {
    if (edit != null) {
      aeronaveSelecionada =
      aeronaves.contains(edit['aeronave']) ? edit['aeronave'] : null;
      alunoSelecionado = alunos.contains(edit['aluno']) ? edit['aluno'] : null;
      instrutorSelecionado =
      instrutores.contains(edit['instrutor']) ? edit['instrutor'] : null;
      partida = edit['partida'];
      destino = edit['destino'];
      tipoVoo =
      ['Regular', 'Instrucional', 'Emergencial'].contains(edit['tipoVoo'])
          ? edit['tipoVoo']
          : 'Regular';
      DateTime dt = DateTime.parse(edit['data']);
      dataAgendamento = DateTime(dt.year, dt.month, dt.day);
      horarioAgendamento = TimeOfDay(hour: dt.hour, minute: dt.minute);
      status = edit['status'];
      this.edit = edit;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          Text(edit != null ? 'Editar Agendamento' : 'Novo Agendamento'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Aeronave'),
                  items: aeronaves
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  value: aeronaveSelecionada,
                  onChanged: (val) => setState(() => aeronaveSelecionada = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Aluno'),
                  items: alunos
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  value: alunoSelecionado,
                  onChanged: (val) => setState(() => alunoSelecionado = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Instrutor'),
                  items: instrutores
                      .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                      .toList(),
                  value: instrutorSelecionado,
                  onChanged: (val) => setState(() => instrutorSelecionado = val),
                ),
                TextFormField(
                  initialValue: partida,
                  decoration: InputDecoration(labelText: 'Partida'),
                  onChanged: (val) => partida = val,
                ),
                TextFormField(
                  initialValue: destino,
                  decoration: InputDecoration(labelText: 'Destino'),
                  onChanged: (val) => destino = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Tipo de Voo'),
                  items: ['Regular', 'Instrucional', 'Emergencial']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: tipoVoo,
                  onChanged: (val) => setState(() => tipoVoo = val!),
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

    DateTime dataCompleta = DateTime(
      dataAgendamento!.year,
      dataAgendamento!.month,
      dataAgendamento!.day,
      horarioAgendamento!.hour,
      horarioAgendamento!.minute,
    );

    final novoAgendamento = {
      'aeronave': aeronaveSelecionada,
      'aluno': alunoSelecionado,
      'instrutor': instrutorSelecionado,
      'partida': partida,
      'destino': destino,
      'tipoVoo': tipoVoo,
      'data': dataCompleta.toIso8601String(),
      'status': status,
    };

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
    tipoVoo = 'Regular';
    dataAgendamento = null;
    horarioAgendamento = null;
    status = 'Pendente';
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
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (horario != null) setState(() => horarioAgendamento = horario);
  }
}

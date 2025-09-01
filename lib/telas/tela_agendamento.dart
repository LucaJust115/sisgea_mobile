import 'package:flutter/material.dart';

class TelaAgendamento extends StatefulWidget {
  @override
  _TelaAgendamentoState createState() => _TelaAgendamentoState();
}

class _TelaAgendamentoState extends State<TelaAgendamento> {
  // Campos do formulário
  String? aeronaveSelecionada;
  String? alunoSelecionado;
  String? instrutorSelecionado;
  String partida = '';
  String destino = '';
  String tipoVoo = 'Regular';
  DateTime? dataAgendamento;
  TimeOfDay? horarioAgendamento; // NOVO CAMPO PARA HORÁRIO
  String status = 'Pendente';

  // Listas de seleção (vão vir do backend futuramente)
  List<String> aeronaves = [];
  List<String> alunos = [];
  List<String> instrutores = [];

  @override
  void initState() {
    super.initState();
    // futuramente: carregar listas via API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendamento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Lista de agendamentos será exibida aqui',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormularioAgendamento(),
        child: Icon(Icons.add),
        tooltip: 'Novo Agendamento',
      ),
    );
  }

  void _abrirFormularioAgendamento() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Agendamento'),
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
                  decoration: InputDecoration(labelText: 'Partida'),
                  onChanged: (val) => partida = val,
                ),
                TextFormField(
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

                // Botão para selecionar a data
                ElevatedButton(
                  onPressed: _selecionarData,
                  child: Text(dataAgendamento == null
                      ? 'Selecionar Data'
                      : '${dataAgendamento!.year}-${_twoDigits(dataAgendamento!.month)}-${_twoDigits(dataAgendamento!.day)}'),
                ),
                SizedBox(height: 10),

                // Botão para selecionar o horário
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
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (dataAgendamento != null && horarioAgendamento != null) {
                  DateTime dataCompleta = DateTime(
                    dataAgendamento!.year,
                    dataAgendamento!.month,
                    dataAgendamento!.day,
                    horarioAgendamento!.hour,
                    horarioAgendamento!.minute,
                  );

                  // futuramente: enviar dataCompleta para a API
                  print('Data e horário selecionados: $dataCompleta');
                }
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() => dataAgendamento = data);
    }
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
    if (horario != null) {
      setState(() => horarioAgendamento = horario);
    }
  }
}

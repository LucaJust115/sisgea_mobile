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
  final String apiUrl = "${AppConfig.apiUrl}/api/diarios-bordo";
  List<Map<String, dynamic>> diarios = [];
  List<Map<String, dynamic>> aeronaves = [];
  List<Map<String, dynamic>> alunos = [];
  List<Map<String, dynamic>> instrutores = [];

  Map<String, dynamic>? edit;
  final _formKey = GlobalKey<FormState>();

  // Dropdowns
  String? aeronaveIdSelecionado;
  String? alunoIdSelecionado;
  String? instrutorIdSelecionado;

  // Data e Hora
  DateTime? dataSelecionada;
  DateTime? dataDecolagemSelecionada;
  TimeOfDay? horaDecolagemSelecionada;
  DateTime? dataPousoSelecionada;
  TimeOfDay? horaPousoSelecionada;
  DateTime? dataCorteSelecionada;
  TimeOfDay? horaCorteSelecionada;

  // Controllers
  final TextEditingController nroDiario = TextEditingController();
  final TextEditingController funcaoAluno = TextEditingController();
  final TextEditingController funcaoInstrutor = TextEditingController();
  final TextEditingController horaAeronave = TextEditingController();
  final TextEditingController localDecolagem = TextEditingController();
  final TextEditingController localPouso = TextEditingController();
  final TextEditingController horasDiu = TextEditingController();
  final TextEditingController horasNot = TextEditingController();
  final TextEditingController horasVfr = TextEditingController();
  final TextEditingController horasIfr = TextEditingController();
  final TextEditingController horasIfrC = TextEditingController();
  final TextEditingController combustivel = TextEditingController();
  final TextEditingController ciclos = TextEditingController();
  final TextEditingController pob = TextEditingController();
  final TextEditingController carga = TextEditingController();
  final TextEditingController nat = TextEditingController();
  final TextEditingController ocorrencias = TextEditingController();

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    await Future.wait([
      _carregar(),
      _carregarAeronaves(),
      _carregarAlunos(),
      _carregarInstrutores(),
    ]);
    setState(() => carregando = false);
  }

  Future<void> _carregar() async {
    try {
      final r = await http.get(Uri.parse(apiUrl));
      if (r.statusCode == 200) {
        setState(() {
          diarios = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(r.bodyBytes)));
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar diários: $e");
    }
  }

  Future<void> _carregarAeronaves() async {
    try {
      final r = await http.get(Uri.parse("${AppConfig.apiUrl}/api/aeronaves"));
      if (r.statusCode == 200) {
        setState(() {
          aeronaves = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(r.bodyBytes)));
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar aeronaves: $e");
    }
  }

  Future<void> _carregarAlunos() async {
    try {
      final r = await http.get(Uri.parse("${AppConfig.apiUrl}/api/alunos"));
      if (r.statusCode == 200) {
        setState(() {
          alunos = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(r.bodyBytes)));
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar alunos: $e");
    }
  }

  Future<void> _carregarInstrutores() async {
    try {
      final r = await http.get(Uri.parse("${AppConfig.apiUrl}/api/instrutores"));
      if (r.statusCode == 200) {
        setState(() {
          instrutores = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(r.bodyBytes)));
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar instrutores: $e");
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação adicional dos dropdowns e datas
    if (aeronaveIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione uma aeronave")),
      );
      return;
    }
    if (alunoIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um aluno")),
      );
      return;
    }
    if (instrutorIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um instrutor")),
      );
      return;
    }
    if (dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione a data")),
      );
      return;
    }
    if (dataDecolagemSelecionada == null || horaDecolagemSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione data e hora de decolagem")),
      );
      return;
    }
    if (dataPousoSelecionada == null || horaPousoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione data e hora de pouso")),
      );
      return;
    }
    if (dataCorteSelecionada == null || horaCorteSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione data e hora de corte")),
      );
      return;
    }

    // Monta as datas completas
    final dataDecolagemCompleta = DateTime(
      dataDecolagemSelecionada!.year,
      dataDecolagemSelecionada!.month,
      dataDecolagemSelecionada!.day,
      horaDecolagemSelecionada!.hour,
      horaDecolagemSelecionada!.minute,
    );

    final dataPousoCompleta = DateTime(
      dataPousoSelecionada!.year,
      dataPousoSelecionada!.month,
      dataPousoSelecionada!.day,
      horaPousoSelecionada!.hour,
      horaPousoSelecionada!.minute,
    );

    final dataCorteCompleta = DateTime(
      dataCorteSelecionada!.year,
      dataCorteSelecionada!.month,
      dataCorteSelecionada!.day,
      horaCorteSelecionada!.hour,
      horaCorteSelecionada!.minute,
    );

    final dataJson = {
      "aeronaveId": aeronaveIdSelecionado,
      "nroDiario": int.tryParse(nroDiario.text),
      "alunoId": alunoIdSelecionado,
      "instrutorId": instrutorIdSelecionado,
      "data": "${dataSelecionada!.year.toString().padLeft(4, '0')}-${dataSelecionada!.month.toString().padLeft(2, '0')}-${dataSelecionada!.day.toString().padLeft(2, '0')}",
      "funcaoAluno": funcaoAluno.text,
      "funcaoInstrutor": funcaoInstrutor.text,
      "horaAeronave": _float(horaAeronave.text),
      "dataDecolagem": dataDecolagemCompleta.toUtc().toIso8601String(),
      "dataPouso": dataPousoCompleta.toUtc().toIso8601String(),
      "localDecolagem": localDecolagem.text.isEmpty ? null : localDecolagem.text,
      "localPouso": localPouso.text.isEmpty ? null : localPouso.text,
      "dataCorte": dataCorteCompleta.toUtc().toIso8601String(),
      "horasDiu": _float(horasDiu.text),
      "horasNot": _float(horasNot.text),
      "horasVfr": _float(horasVfr.text),
      "horasIfr": _float(horasIfr.text),
      "horasIfrC": _float(horasIfrC.text),
      "combustivelUtilizado": combustivel.text.isEmpty ? null : combustivel.text,
      "ciclos": int.tryParse(ciclos.text),
      "pob": int.tryParse(pob.text),
      "carga": carga.text.isEmpty ? null : carga.text,
      "nat": nat.text,
      "ocorrencias": ocorrencias.text.isEmpty ? null : ocorrencias.text,
    };

    try {
      http.Response r;
      if (edit != null) {
        r = await http.put(
          Uri.parse("$apiUrl/${edit!['id']}"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(dataJson)),
        );
      } else {
        r = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: utf8.encode(jsonEncode(dataJson)),
        );
      }

      if (r.statusCode == 200 || r.statusCode == 201) {
        Navigator.pop(context);
        await _carregar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(edit != null ? "Atualizado!" : "Criado!")),
        );
      } else {
        final erro = jsonDecode(utf8.decode(r.bodyBytes));
        debugPrint("Erro: ${erro['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${erro['error'] ?? r.body}")),
        );
      }
    } catch (e) {
      debugPrint("Exceção ao salvar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }
  }

  double? _float(String v) => v.isEmpty ? null : double.tryParse(v);

  void _editar(diario) {
    edit = diario;

    aeronaveIdSelecionado = diario["aeronaveId"];
    alunoIdSelecionado = diario["alunoId"];
    instrutorIdSelecionado = diario["instrutorId"];

    nroDiario.text = diario["nroDiario"]?.toString() ?? "";

    // Parse data simples
    if (diario["data"] != null) {
      try {
        dataSelecionada = DateTime.parse(diario["data"]);
      } catch (e) {
        dataSelecionada = null;
      }
    }

    funcaoAluno.text = diario["funcaoAluno"] ?? "";
    funcaoInstrutor.text = diario["funcaoInstrutor"] ?? "";
    horaAeronave.text = diario["horaAeronave"]?.toString() ?? "";

    // Parse data/hora decolagem
    if (diario["dataDecolagem"] != null) {
      try {
        final dt = DateTime.parse(diario["dataDecolagem"]);
        dataDecolagemSelecionada = dt;
        horaDecolagemSelecionada = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (e) {
        dataDecolagemSelecionada = null;
        horaDecolagemSelecionada = null;
      }
    }

    // Parse data/hora pouso
    if (diario["dataPouso"] != null) {
      try {
        final dt = DateTime.parse(diario["dataPouso"]);
        dataPousoSelecionada = dt;
        horaPousoSelecionada = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (e) {
        dataPousoSelecionada = null;
        horaPousoSelecionada = null;
      }
    }

    localDecolagem.text = diario["localDecolagem"] ?? "";
    localPouso.text = diario["localPouso"] ?? "";

    // Parse data/hora corte
    if (diario["dataCorte"] != null) {
      try {
        final dt = DateTime.parse(diario["dataCorte"]);
        dataCorteSelecionada = dt;
        horaCorteSelecionada = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (e) {
        dataCorteSelecionada = null;
        horaCorteSelecionada = null;
      }
    }

    horasDiu.text = diario["horasDiu"]?.toString() ?? "";
    horasNot.text = diario["horasNot"]?.toString() ?? "";
    horasVfr.text = diario["horasVfr"]?.toString() ?? "";
    horasIfr.text = diario["horasIfr"]?.toString() ?? "";
    horasIfrC.text = diario["horasIfrC"]?.toString() ?? "";
    combustivel.text = diario["combustivelUtilizado"]?.toString() ?? "";
    ciclos.text = diario["ciclos"]?.toString() ?? "";
    pob.text = diario["pob"]?.toString() ?? "";
    carga.text = diario["carga"]?.toString() ?? "";
    nat.text = diario["nat"] ?? "";
    ocorrencias.text = diario["ocorrencias"] ?? "";

    _abrirForm();
  }

  Future<void> _deletar(id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar Exclusão"),
        content: const Text("Deseja realmente excluir este diário?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await http.delete(Uri.parse("$apiUrl/$id"));
      _carregar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diário excluído!")),
      );
    }
  }

  void _limparCampos() {
    aeronaveIdSelecionado = null;
    alunoIdSelecionado = null;
    instrutorIdSelecionado = null;
    dataSelecionada = null;
    dataDecolagemSelecionada = null;
    horaDecolagemSelecionada = null;
    dataPousoSelecionada = null;
    horaPousoSelecionada = null;
    dataCorteSelecionada = null;
    horaCorteSelecionada = null;
    for (var c in [
      nroDiario, funcaoAluno, funcaoInstrutor, horaAeronave,
      localDecolagem, localPouso, horasDiu, horasNot,
      horasVfr, horasIfr, horasIfrC, combustivel, ciclos, pob, carga, nat, ocorrencias
    ]) {
      c.clear();
    }
  }

  void _abrirForm() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(edit != null ? "Editar Diário" : "Novo Diário"),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Dropdown Aeronave
                    DropdownButtonFormField<String>(
                      value: aeronaveIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: "Aeronave",
                        border: OutlineInputBorder(),
                      ),
                      items: aeronaves.map((a) {
                        return DropdownMenuItem<String>(
                          value: a['id'],
                          child: Text("${a['matricula']} - ${a['modelo'] ?? ''}"),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => aeronaveIdSelecionado = v),
                      validator: null, // Remove validação do FormField
                    ),
                    const SizedBox(height: 8),

                    // Dropdown Aluno
                    DropdownButtonFormField<String>(
                      value: alunoIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: "Aluno",
                        border: OutlineInputBorder(),
                      ),
                      items: alunos.map((a) {
                        return DropdownMenuItem<String>(
                          value: a['id'],
                          child: Text(a['nome'] ?? 'Sem nome'),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => alunoIdSelecionado = v),
                      validator: null, // Remove validação do FormField
                    ),
                    const SizedBox(height: 8),

                    // Dropdown Instrutor
                    DropdownButtonFormField<String>(
                      value: instrutorIdSelecionado,
                      decoration: const InputDecoration(
                        labelText: "Instrutor",
                        border: OutlineInputBorder(),
                      ),
                      items: instrutores.map((i) {
                        return DropdownMenuItem<String>(
                          value: i['id'],
                          child: Text(i['nome'] ?? 'Sem nome'),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => instrutorIdSelecionado = v),
                      validator: null, // Remove validação do FormField
                    ),
                    const SizedBox(height: 8),

                    campo(nroDiario, "Número do Diário", number: true),

                    // Seletor de Data
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ElevatedButton.icon(
                        onPressed: () => _selecionarData(setDialogState),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(dataSelecionada == null
                            ? 'Selecionar Data'
                            : '${dataSelecionada!.year}-${_twoDigits(dataSelecionada!.month)}-${_twoDigits(dataSelecionada!.day)}'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),

                    campo(funcaoAluno, "Função Aluno"),
                    campo(funcaoInstrutor, "Função Instrutor"),
                    campo(horaAeronave, "Horímetro Inicial", number: true),

                    // Seletor Data/Hora Decolagem
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data e Hora de Decolagem:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarDataDecolagem(setDialogState),
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Text(dataDecolagemSelecionada == null
                                      ? 'Data'
                                      : '${_twoDigits(dataDecolagemSelecionada!.day)}/${_twoDigits(dataDecolagemSelecionada!.month)}/${dataDecolagemSelecionada!.year}'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarHoraDecolagem(setDialogState),
                                  icon: const Icon(Icons.access_time, size: 16),
                                  label: Text(horaDecolagemSelecionada == null
                                      ? 'Hora'
                                      : '${_twoDigits(horaDecolagemSelecionada!.hour)}:${_twoDigits(horaDecolagemSelecionada!.minute)}'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Seletor Data/Hora Pouso
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data e Hora de Pouso:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarDataPouso(setDialogState),
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Text(dataPousoSelecionada == null
                                      ? 'Data'
                                      : '${_twoDigits(dataPousoSelecionada!.day)}/${_twoDigits(dataPousoSelecionada!.month)}/${dataPousoSelecionada!.year}'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarHoraPouso(setDialogState),
                                  icon: const Icon(Icons.access_time, size: 16),
                                  label: Text(horaPousoSelecionada == null
                                      ? 'Hora'
                                      : '${_twoDigits(horaPousoSelecionada!.hour)}:${_twoDigits(horaPousoSelecionada!.minute)}'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    campo(localDecolagem, "Local Decolagem", obrigatorio: false),
                    campo(localPouso, "Local Pouso", obrigatorio: false),

                    // Seletor Data/Hora Corte
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data e Hora de Corte:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarDataCorte(setDialogState),
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  label: Text(dataCorteSelecionada == null
                                      ? 'Data'
                                      : '${_twoDigits(dataCorteSelecionada!.day)}/${_twoDigits(dataCorteSelecionada!.month)}/${dataCorteSelecionada!.year}'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _selecionarHoraCorte(setDialogState),
                                  icon: const Icon(Icons.access_time, size: 16),
                                  label: Text(horaCorteSelecionada == null
                                      ? 'Hora'
                                      : '${_twoDigits(horaCorteSelecionada!.hour)}:${_twoDigits(horaCorteSelecionada!.minute)}'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    campo(horasDiu, "Horas DIU", number: true, obrigatorio: false),
                    campo(horasNot, "Horas NOT", number: true, obrigatorio: false),
                    campo(horasVfr, "Horas VFR", number: true, obrigatorio: false),
                    campo(horasIfr, "Horas IFR", number: true, obrigatorio: false),
                    campo(horasIfrC, "Horas IFR C", number: true, obrigatorio: false),
                    campo(combustivel, "Combustível (ex: 300lbs)"),
                    campo(ciclos, "Ciclos", number: true),
                    campo(pob, "POB", number: true),
                    campo(carga, "Carga (ex: 100kg)"),
                    campo(nat, "Natureza"),
                    campo(ocorrencias, "Ocorrências", max: 3, obrigatorio: false),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _limparCampos();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(onPressed: _salvar, child: const Text("Salvar")),
          ],
        ),
      ),
    );
  }

  Widget campo(TextEditingController c, String t, {bool number = false, int max = 1, bool obrigatorio = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: t),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        maxLines: max,
        validator: obrigatorio ? (v) => v == null || v.isEmpty ? "Campo obrigatório" : null : null,
      ),
    );
  }

  String _getNomeAeronave(String? id) {
    if (id == null) return "N/A";
    final aeronave = aeronaves.firstWhere((a) => a['id'] == id, orElse: () => {});
    return aeronave['matricula'] ?? "N/A";
  }

  String _getNomeAluno(String? id) {
    if (id == null) return "N/A";
    final aluno = alunos.firstWhere((a) => a['id'] == id, orElse: () => {});
    return aluno['nome'] ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diário de Bordo")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          edit = null;
          _limparCampos();
          _abrirForm();
        },
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : diarios.isEmpty
          ? const Center(child: Text("Nenhum diário cadastrado"))
          : ListView.builder(
        itemCount: diarios.length,
        itemBuilder: (_, i) {
          final d = diarios[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text("Diário #${d['nroDiario']} - ${_getNomeAeronave(d['aeronaveId'])}"),
              subtitle: Text("Aluno: ${_getNomeAluno(d['alunoId'])} | Data: ${d['data']}"),
              onTap: () => _editar(d),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletar(d['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    nroDiario.dispose();
    funcaoAluno.dispose();
    funcaoInstrutor.dispose();
    horaAeronave.dispose();
    localDecolagem.dispose();
    localPouso.dispose();
    horasDiu.dispose();
    horasNot.dispose();
    horasVfr.dispose();
    horasIfr.dispose();
    horasIfrC.dispose();
    combustivel.dispose();
    ciclos.dispose();
    pob.dispose();
    carga.dispose();
    nat.dispose();
    ocorrencias.dispose();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _selecionarData(Function setState) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataSelecionada = data);
  }

  void _selecionarDataDecolagem(Function setState) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataDecolagemSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataDecolagemSelecionada = data);
  }

  void _selecionarHoraDecolagem(Function setState) async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaDecolagemSelecionada ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora != null) setState(() => horaDecolagemSelecionada = hora);
  }

  void _selecionarDataPouso(Function setState) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataPousoSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataPousoSelecionada = data);
  }

  void _selecionarHoraPouso(Function setState) async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaPousoSelecionada ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora != null) setState(() => horaPousoSelecionada = hora);
  }

  void _selecionarDataCorte(Function setState) async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: dataCorteSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataCorteSelecionada = data);
  }

  void _selecionarHoraCorte(Function setState) async {
    TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaCorteSelecionada ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (hora != null) setState(() => horaCorteSelecionada = hora);
  }
}
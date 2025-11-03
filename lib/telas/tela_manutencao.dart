import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class TelaManutencao extends StatefulWidget {
  @override
  _TelaManutencaoState createState() => _TelaManutencaoState();
}

class _TelaManutencaoState extends State<TelaManutencao> {
  final String apiUrl = AppConfig.apiUrl + "/api/manutencoes";
  final String apiAeronaves = AppConfig.apiUrl + "/api/aeronaves";

  List manutencoes = [];
  List aeronaves = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarAeronaves();
    _buscarManutencoes();
  }

  Future<void> _buscarAeronaves() async {
    try {
      final response = await http.get(Uri.parse(apiAeronaves));
      if (response.statusCode == 200) {
        setState(() {
          aeronaves = json.decode(response.body);
        });
      }
    } catch (_) {}
  }

  Future<void> _buscarManutencoes() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          manutencoes = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      _mostrarErro("Falha ao buscar manutenções");
    }
  }

  Future<void> _salvarManutencao(Map<String, dynamic> manutencao, {bool editar = false}) async {
    manutencao["status"] = manutencao["status"] ?? "Pendente";
    manutencao["data_est_man"] = manutencao["data_est_man"] ?? DateFormat("yyyy-MM-dd").format(DateTime.now());

    try {
      final response = editar
          ? await http.put(
        Uri.parse("$apiUrl/${manutencao['id']}?forcar=false"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(manutencao),
      )
          : await http.post(
        Uri.parse("$apiUrl?forcar=false"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(manutencao),
      );
      print(json.encode(manutencao));
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        _buscarManutencoes();
      } else {
        print(response.body);
        _mostrarErro("Erro ao salvar manutenção");
      }
    } catch (e) {
      _mostrarErro("Erro de comunicação com o servidor");
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _abrirFormulario({Map<String, dynamic>? manutencao}) {
    final TextEditingController descricaoController =
    TextEditingController(text: manutencao?['descricao'] ?? "");

    final TextEditingController dataController =
    TextEditingController(
        text: manutencao?['data_est_man'] != null
            ? DateFormat("yyyy-MM-dd").format(DateTime.parse(manutencao!['data_est_man']))
            : ""
    );

    String? matriculaAeronave = manutencao?['aeronave']?['matricula'];
    String? status = manutencao?['status'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(manutencao == null ? "Nova Manutenção" : "Editar Manutenção"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Aeronave"),
                value: matriculaAeronave,
                items: aeronaves.map<DropdownMenuItem<String>>((a) {
                  return DropdownMenuItem(
                      value: a['matricula'],
                      child: Text(a['matricula'])
                  );
                }).toList(),
                onChanged: (value) => matriculaAeronave = value,
              ),
              TextField(
                controller: descricaoController,
                decoration: InputDecoration(labelText: "Descrição"),
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: "Status"),
                items: [
                  "Pendente",
                  "Em Andamento",
                  "Concluída"
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => status = value,
              ),
              TextField(
                controller: dataController,
                decoration: InputDecoration(labelText: "Data Estimada (yyyy-MM-dd)"),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2050)
                  );
                  if (picked != null) {
                    dataController.text = DateFormat("yyyy-MM-dd").format(picked);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (descricaoController.text.isEmpty ||
                  dataController.text.isEmpty ||
                  matriculaAeronave == null ||
                  status == null) {
                _mostrarErro("Preencha todos os campos");
                return;
              }

              _salvarManutencao({
                "descricao": descricaoController.text,
                "data_est_man": dataController.text,
                "status": status,
                "aeronave": {"matricula": matriculaAeronave}
              }, editar: manutencao != null);
            },
            child: Text("Salvar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manutenções")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _abrirFormulario(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: manutencoes.length,
        itemBuilder: (context, i) {
          final m = manutencoes[i];
          return ListTile(
            title: Text(m['aeronave']?['matricula'] ?? "Sem aeronave"),
            subtitle: Text("${m['descricao']} - ${m['status']} - ${m['data_est_man']}"),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _abrirFormulario(manutencao: m),
            ),
          );
        },
      ),
    );
  }
}

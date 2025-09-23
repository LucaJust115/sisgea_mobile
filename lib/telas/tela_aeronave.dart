import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisgea_mobile/config.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


class TelaAeronave extends StatefulWidget {
  @override
  _TelaAeronaveState createState() => _TelaAeronaveState();
}

class _TelaAeronaveState extends State<TelaAeronave> {
  final String apiUrl = AppConfig.apiUrl + "/api/aeronaves";

  // Lista de aeronaves
  List<Map<String, dynamic>> aeronaves = [];

  // Campos do formulário
  String matricula = '';
  String modelo = '';
  String fabricante = '';
  String habilitacao = 'VFR-D';
  String tipoVoo = 'Regular';
  double horasVoo = 0.0;

  // Aeronave em edição
  Map<String, dynamic>? edit;

  @override
  void initState() {
    super.initState();
    _fetchAeronaves();
  }

  Future<void> _fetchAeronaves() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          aeronaves = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      print("Erro ao buscar aeronaves: $e");
    }
  }

  Future<void> _salvarAeronaveAPI(Map<String, dynamic> aeronave) async {
    try {
      if (edit != null) {
        // PUT - atualizar aeronave existente
        final response = await http.put(
          Uri.parse("$apiUrl/${edit!['id']}"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(aeronave),
        );
        if (response.statusCode == 200) {
          _fetchAeronaves();
        }
      } else {
        // POST - cadastrar nova aeronave
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: json.encode(aeronave),
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          _fetchAeronaves();
        }
      }
    } catch (e) {
      print("Erro ao salvar aeronave: $e");
    }
  }

  Future<void> _deletarAeronaveAPI(Map<String, dynamic> aer) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/${aer['id']}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          aeronaves.remove(aer);
        });
      }
    } catch (e) {
      print("Erro ao deletar aeronave: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aeronaves')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: aeronaves.isEmpty
                  ? Center(child: Text('Nenhuma aeronave cadastrada'))
                  : ListView.builder(
                itemCount: aeronaves.length,
                itemBuilder: (context, index) {
                  final aer = aeronaves[index];
                  return Card(
                    child: ListTile(
                      title: Text('${aer['matricula']} - ${aer['modelo']}'),
                      subtitle: Text('Fabricante: ${aer['fabricante']} | Habilitação: ${aer['habilitacao']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _abrirFormularioAeronave(edit: aer),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarAeronaveAPI(aer),
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
        onPressed: () => _abrirFormularioAeronave(),
        child: Icon(Icons.add),
        tooltip: 'Nova Aeronave',
      ),
    );
  }

  void _abrirFormularioAeronave({Map<String, dynamic>? edit}) {
    if (edit != null) {
      matricula = edit['matricula'];
      modelo = edit['modelo'];
      fabricante = edit['fabricante'];
      habilitacao = edit['habilitacao'];
      tipoVoo = edit['tipo_de_voo'];
      horasVoo = (edit['horas_de_voo'] as num).toDouble();
      this.edit = edit;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(edit != null ? 'Editar Aeronave' : 'Nova Aeronave'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: matricula,
                  decoration: InputDecoration(labelText: 'Matrícula'),
                  onChanged: (val) => matricula = val.toUpperCase(),
                ),
                TextFormField(
                  initialValue: modelo,
                  decoration: InputDecoration(labelText: 'Modelo'),
                  onChanged: (val) => modelo = val,
                ),
                TextFormField(
                  initialValue: fabricante,
                  decoration: InputDecoration(labelText: 'Fabricante'),
                  onChanged: (val) => fabricante = val,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Habilitação'),
                  items: ['VFR-D', 'IFR', 'VFR-N']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: habilitacao,
                  onChanged: (val) => setState(() => habilitacao = val!),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Tipo de Voo'),
                  items: ['Regular', 'Instrucional', 'Emergencial']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: tipoVoo,
                  onChanged: (val) => setState(() => tipoVoo = val!),
                ),
                TextFormField(
                  initialValue: horasVoo.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Horas de Voo'),
                  onChanged: (val) => horasVoo = double.tryParse(val) ?? 0.0,
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
              onPressed: _salvarAeronave,
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _salvarAeronave() {
    if (matricula.isEmpty || modelo.isEmpty || fabricante.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    final prefixosValidos = ['PT', 'PP', 'PR', 'PS', 'PU'];
    if (matricula.length < 2 || !prefixosValidos.contains(matricula.substring(0, 2))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prefixo da matrícula inválido')),
      );
      return;
    }

    final novaAeronave = {
      'matricula': matricula,
      'modelo': modelo,
      'fabricante': fabricante,
      'habilitacao': habilitacao,
      'tipo_de_voo': tipoVoo,
      'horas_de_voo': horasVoo,
    };

    _salvarAeronaveAPI(novaAeronave);

    _resetFormulario();
    Navigator.pop(context);
  }

  void _resetFormulario() {
    matricula = '';
    modelo = '';
    fabricante = '';
    habilitacao = 'VFR-D';
    tipoVoo = 'Regular';
    horasVoo = 0.0;
    edit = null;
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisgea_mobile/config.dart';
import 'package:flutter/services.dart';

class TelaAeronave extends StatefulWidget {
  @override
  _TelaAeronaveState createState() => _TelaAeronaveState();
}

class _TelaAeronaveState extends State<TelaAeronave> {
  final String apiUrl = AppConfig.apiUrl + "/api/aeronaves";

  List<Map<String, dynamic>> aeronaves = [];

  String matricula = '';
  String modelo = '';
  String fabricante = '';
  String habilitacao = 'MNTE';
  String tipoVoo = 'VFR-D';
  double horasVoo = 0.0;

  Map<String, dynamic>? edit;

  final _matriculaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAeronaves();
  }

  Future<void> _fetchAeronaves() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          aeronaves = data.cast<Map<String, dynamic>>();
        });
      } else {
        print("Erro ao buscar aeronaves: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao buscar aeronaves: $e");
    }
  }

  Future<void> _salvarAeronaveAPI(Map<String, dynamic> aeronave) async {
    try {
      http.Response response;

      if (edit != null) {
        response = await http.put(
          Uri.parse("$apiUrl/${edit!['matricula']}"),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(aeronave),
        );
      } else {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json; charset=UTF-8"},
          body: json.encode(aeronave),
        );
      }

      print("JSON ENVIADO:");
      print(json.encode(aeronave));
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchAeronaves();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aeronave salva com sucesso!')),
        );
      } else if (response.statusCode == 302) {
        _fetchAeronaves();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aeronave salva (redirecionamento)!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar aeronave (${response.statusCode})')),
        );
      }
    } catch (e) {
      print("Erro ao salvar aeronave: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar aeronave')),
      );
    }
  }

  Future<void> _deletarAeronaveAPI(Map<String, dynamic> aer) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/${aer['matricula']}"));
      if (response.statusCode == 200) {
        setState(() {
          aeronaves.remove(aer);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aeronave excluída com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir aeronave (${response.statusCode})')),
        );
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
                      subtitle: Text(
                          'Fabricante: ${aer['fabricante']} | Habilitação: ${aer['habilitacao']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _abrirFormularioAeronave(edit: aer),
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
      _matriculaController.text = matricula;
    } else {
      _resetFormulario();
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
                  controller: _matriculaController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\-]')),
                  ],
                  decoration: InputDecoration(labelText: 'Matrícula (ex: PS-ABC)'),
                  onChanged: (val) {
                    String text = val.toUpperCase().replaceAll('-', '');
                    if (text.length > 2) {
                      text = text.substring(0, 2) + '-' + text.substring(2);
                    }
                    _matriculaController.value = TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                    matricula = text;
                  },
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
                  items: ['MNTE', 'MLTE', 'MNAF']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: habilitacao,
                  onChanged: (val) => setState(() => habilitacao = val!),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Tipo de Voo'),
                  items: ['VFR-D', 'VFR-N', 'IFR']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: tipoVoo,
                  onChanged: (val) => setState(() => tipoVoo = val!),
                ),
                TextFormField(
                  initialValue: horasVoo.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Horas de Voo'),
                  onChanged: (val) =>
                  horasVoo = double.tryParse(val) ?? 0.0,
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
    matricula = matricula.toUpperCase();

    if (matricula.isEmpty || modelo.isEmpty || fabricante.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    if (!RegExp(r'^(PP|PR|PT|PS)-[A-Z]{3}$').hasMatch(matricula)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matrícula inválida! Use formato ex: PS-ABC')),
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
    habilitacao = 'MNTE';
    tipoVoo = 'VFR-D';
    horasVoo = 0.0;
    edit = null;
    _matriculaController.clear();
  }
}

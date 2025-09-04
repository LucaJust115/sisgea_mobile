import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TelaManutencao extends StatefulWidget {
  @override
  _TelaManutencaoState createState() => _TelaManutencaoState();
}

class _TelaManutencaoState extends State<TelaManutencao> {
  List<Map<String, dynamic>> manutencoes = [];

  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  DateTime? dataEstimada;

  Map<String, dynamic>? editando;

  void salvarManutencao() {
    if (descricaoController.text.isEmpty ||
        statusController.text.isEmpty ||
        dataEstimada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    final novaManutencao = {
      "id": editando?['id'] ?? DateTime.now().toString(),
      "descricao": descricaoController.text,
      "status": statusController.text,
      "data_est_man": dataEstimada,
    };

    setState(() {
      if (editando != null) {
        final index = manutencoes.indexWhere((m) => m['id'] == editando!['id']);
        if (index != -1) {
          manutencoes[index] = novaManutencao;
        }
        editando = null;
      } else {
        manutencoes.add(novaManutencao);
      }
    });

    descricaoController.clear();
    statusController.clear();
    dataEstimada = null;
  }

  void editarManutencao(Map<String, dynamic> manutencao) {
    setState(() {
      editando = manutencao;
      descricaoController.text = manutencao['descricao'];
      statusController.text = manutencao['status'];

      final rawDate = manutencao['data_est_man'];
      if (rawDate is String) {
        dataEstimada = DateTime.tryParse(rawDate);
      } else if (rawDate is DateTime) {
        dataEstimada = rawDate;
      }
    });
  }

  void deletarManutencao(String id) {
    setState(() {
      manutencoes.removeWhere((m) => m['id'] == id);
    });
  }

  Future<void> selecionarData(BuildContext context) async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: dataEstimada ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selecionada != null) {
      setState(() {
        dataEstimada = selecionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manutenções")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: "Descrição"),
                ),
                TextField(
                  controller: statusController,
                  decoration: InputDecoration(labelText: "Status"),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dataEstimada == null
                            ? "Nenhuma data selecionada"
                            : DateFormat('dd/MM/yyyy').format(dataEstimada!),
                      ),
                    ),
                    TextButton(
                      onPressed: () => selecionarData(context),
                      child: Text("Selecionar Data"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: salvarManutencao,
                  child: Text(editando != null ? "Atualizar" : "Salvar"),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: manutencoes.length,
              itemBuilder: (context, index) {
                final m = manutencoes[index];
                return ListTile(
                  title: Text(m['descricao']),
                  subtitle: Text("Status: ${m['status']}"),
                  trailing: Text(
                        () {
                      final rawDate = m['data_est_man'];

                      if (rawDate == null) return "Sem data";

                      DateTime date;

                      if (rawDate is String) {
                        try {
                          date = DateTime.parse(rawDate);
                        } catch (e) {
                          return "Data inválida";
                        }
                      } else if (rawDate is DateTime) {
                        date = rawDate;
                      } else {
                        return "Data inválida";
                      }

                      return DateFormat('dd/MM/yyyy').format(date);
                    }(),
                  ),
                  onTap: () => editarManutencao(m),
                  onLongPress: () => deletarManutencao(m['id']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

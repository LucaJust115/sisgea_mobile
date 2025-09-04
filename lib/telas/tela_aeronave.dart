import 'package:flutter/material.dart';

class TelaAeronave extends StatefulWidget {
  @override
  _TelaAeronaveState createState() => _TelaAeronaveState();
}

class _TelaAeronaveState extends State<TelaAeronave> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aeronaves'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: aeronaves.isEmpty
                  ? Center(
                child: Text(
                  'Nenhuma aeronave cadastrada',
                  style: TextStyle(color: Colors.grey),
                ),
              )
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
                            onPressed: () => _deletarAeronave(aer),
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
    // Se for edição, preenche os campos
    if (edit != null) {
      matricula = edit['matricula'];
      modelo = edit['modelo'];
      fabricante = edit['fabricante'];
      habilitacao = edit['habilitacao'];
      tipoVoo = edit['tipo_de_voo'];
      horasVoo = edit['horas_de_voo'];
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

    // Validação básica do prefixo da matrícula
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

    setState(() {
      if (edit != null) {
        final index = aeronaves.indexOf(edit!);
        if (index != -1) {
          aeronaves[index] = novaAeronave;
        }
        this.edit = null;
      } else {
        aeronaves.add(novaAeronave);
      }
      _resetFormulario();
    });

    Navigator.pop(context);
  }

  void _deletarAeronave(Map<String, dynamic> aer) {
    setState(() => aeronaves.remove(aer));
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

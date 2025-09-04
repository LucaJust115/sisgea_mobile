import 'package:flutter/material.dart';

class TelaDiario extends StatefulWidget {
  const TelaDiario({Key? key}) : super(key: key);

  @override
  _TelaDiarioState createState() => _TelaDiarioState();
}

class _TelaDiarioState extends State<TelaDiario> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para os campos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Bordo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Aqui você poderá integrar a chamada para a API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diário salvo com sucesso!')),
                      );
                    }
                  },
                  child: const Text('Salvar Diário'),
                ),
              ),
            ],
          ),
        ),
      ),
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
    // Liberando os controllers
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
}

import 'package:flutter/material.dart';

class CardFuncionalidade extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Color cor;
  final Widget? tela;

  const CardFuncionalidade({
    Key? key,
    required this.icone,
    required this.titulo,
    required this.cor,
    this.tela,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cor,
      child: InkWell(
        onTap: () {
          if (tela != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => tela!),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$titulo em desenvolvimento')),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 48, color: Colors.white),
              SizedBox(height: 10),
              Text(
                titulo,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con un TextField para la búsqueda.
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Buscar eventos...',
            border: InputBorder.none,
          ),
          autofocus: true,
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
      ),
      body: const Center(
        child: Text(
          'No hay resultados',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

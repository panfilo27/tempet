// lib/src/presentation/pages/search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tempet/src/domain/entities/evento.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_bloc.dart';
import 'package:tempet/src/presentation/blocs/add_event/evento_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Evento> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<EventoBloc>().state;
    if (state is EventoLoaded) {
      _filteredEvents = state.eventos;
    }
    _searchController.addListener(_onSearchChanged);

    // Abrir teclado automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final state = context.read<EventoBloc>().state;
    if (state is EventoLoaded) {
      setState(() {
        _filteredEvents = state.eventos.where((evento) {
          final title = evento.titulo.toLowerCase();
          final details = evento.detalles.toLowerCase();
          return title.contains(query) || details.contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Buscador en el AppBar
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: const InputDecoration(
            hintText: 'Buscar',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: _filteredEvents.isEmpty
          ? const Center(child: Text('No se encontraron eventos'))
          : ListView.builder(
        itemCount: _filteredEvents.length,
        itemBuilder: (context, index) {
          final evento = _filteredEvents[index];
          return ListTile(
            title: Text(evento.titulo),
            subtitle: evento.detalles.isNotEmpty
                ? Text(evento.detalles)
                : null,
            onTap: () => Navigator.pop(context, evento),
          );
        },
      ),
    );
  }
}

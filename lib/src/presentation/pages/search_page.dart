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
  // Controlador para el campo de búsqueda.
  final TextEditingController _searchController = TextEditingController();
  // Lista local para almacenar y filtrar los eventos.
  List<Evento> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    // Inicializamos la lista filtrada con todos los eventos cargados por el Bloc.
    // Esto permite que, antes de cualquier búsqueda, se muestren todos los eventos.
    final state = context.read<EventoBloc>().state;
    if (state is EventoLoaded) {
      _filteredEvents = state.eventos;
    }
    // Se agrega un listener para detectar cambios en el campo de búsqueda.
    _searchController.addListener(_onSearchChanged);
  }

  // Método que se ejecuta cada vez que cambia el texto en el campo de búsqueda.
  void _onSearchChanged() {
    // Convertimos el texto a minúsculas para hacer una búsqueda case-insensitive.
    final query = _searchController.text.toLowerCase();
    final state = context.read<EventoBloc>().state;
    if (state is EventoLoaded) {
      setState(() {
        // Se filtra la lista de eventos usando la propiedad 'descripcion'.
        // Si la descripción contiene el texto ingresado, se incluye en la lista filtrada.
        _filteredEvents = state.eventos.where((evento) {
          return evento.descripcion.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    // Se remueve el listener y se libera el controlador para evitar fugas de memoria.
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Evento'),
      ),
      body: Column(
        children: [
          // Campo de búsqueda con diseño personalizado.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por descripción...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Muestra la lista de eventos filtrados.
          Expanded(
            child: _filteredEvents.isEmpty
                ? const Center(child: Text('No se encontraron eventos'))
                : ListView.builder(
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                final evento = _filteredEvents[index];
                return ListTile(
                  // Se muestra la descripción del evento.
                  title: Text(evento.descripcion),
                  onTap: () {
                    // Al seleccionar un evento, se regresa este evento a la CalendarPage.
                    // Esto se hace con Navigator.pop(context, evento);
                    Navigator.pop(context, evento);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

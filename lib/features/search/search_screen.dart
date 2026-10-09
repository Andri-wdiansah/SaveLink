import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Search links, notes, tags...')),
          ),
          Expanded(child: ListView(children: [
            ListTile(title: Text('Results for: ${controller.text}'), subtitle: const Text('Actual search results connected to SQLite will appear here.')),
          ])),
        ],
      ),
    );
  }
}

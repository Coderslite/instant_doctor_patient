import 'package:flutter/material.dart';
import 'package:instant_doctor/services/LocationService.dart';

class LocationSearch extends StatefulWidget {
  const LocationSearch({super.key});

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  List<dynamic> _suggestions = [];
  final TextEditingController _controller = TextEditingController();

  void _onSearchChanged() {
    if (_controller.text.isNotEmpty) {
      LocationService().getSuggestions(_controller.text).then((suggestions) {
        setState(() {
          _suggestions = suggestions;
        });
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                var suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion['structured_formatting']['main_text']),
                  subtitle: Text(suggestion['structured_formatting']
                          ['secondary_text'] ??
                      ''),
                  onTap: () {
                    // Handle the selection of a suggestion here
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

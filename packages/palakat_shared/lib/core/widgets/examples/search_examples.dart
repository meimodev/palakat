import 'package:flutter/material.dart';
import '../input/input_search_widget.dart';
import '../searchable_dialog_picker.dart';
import '../search_field.dart';
import '../../utils/debouncer.dart';

/// Example implementations of the consolidated search widgets.
///
/// These examples demonstrate how to use the new search widgets
/// in various common scenarios.
class SearchExamples extends StatefulWidget {
  const SearchExamples({super.key});

  @override
  State<SearchExamples> createState() => _SearchExamplesState();
}

class _SearchExamplesState extends State<SearchExamples> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<String> _searchResults = [];
  final List<ExampleItem> _items = [
    ExampleItem(id: 1, name: 'Apple', category: 'Fruit'),
    ExampleItem(id: 2, name: 'Banana', category: 'Fruit'),
    ExampleItem(id: 3, name: 'Carrot', category: 'Vegetable'),
    ExampleItem(id: 4, name: 'Date', category: 'Fruit'),
  ];
  ExampleItem? _selectedItem;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
      _searchResults = query.isEmpty
          ? []
          : ['Result 1 for "$query"', 'Result 2 for "$query"'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Widget Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: Basic SearchField
            _buildSection(
              'Basic SearchField',
              'Simple search with debouncing and loading state',
              SearchField(
                hint: 'Search with API call...',
                onSearch: _performSearch,
                isLoading: _isLoading,
              ),
            ),

            // Example 2: InputSearchWidget with custom styling
            _buildSection(
              'Custom InputSearchWidget',
              'Enhanced input with custom border radius and icons',
              InputSearchWidget(
                hint: 'Custom search field...',
                borderRadius: 12,
                autoClearButton: true,
                debounceMilliseconds: 500,
                onChanged: (value) => debugPrint('Immediate: $value'),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
              ),
            ),

            // Example 3: SearchField with dual callbacks
            _buildSection(
              'Dual Callback SearchField',
              'Immediate local filtering + debounced API calls',
              SearchField(
                controller: _searchController,
                hint: 'Search items...',
                onChanged: (value) {
                  // Immediate callback for local filtering
                  // print('Local filter: $value');
                },
                onSearch: (query) {
                  // Debounced callback for API calls
                  // print('API search: $query');
                },
              ),
            ),

            // Example 4: Dialog Picker Button
            _buildSection(
              'Searchable Dialog Picker',
              'Click to open searchable item picker',
              ElevatedButton(
                onPressed: _showSearchableDialog,
                child: Text(_selectedItem?.name ?? 'Select Item'),
              ),
            ),

            // Search Results Display
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Search Results:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(_searchResults.map((result) => Card(
                child: ListTile(title: Text(result)),
              ))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _showSearchableDialog() async {
    final result = await showDialog<ExampleItem>(
      context: context,
      builder: (context) => SearchableDialogPicker<ExampleItem>(
        title: 'Select Item',
        searchHint: 'Search items...',
        items: _items,
        selectedItem: _selectedItem,
        itemBuilder: (item) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(item.category, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        onFilter: (item, query) =>
            item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query),
        emptyStateMessage: 'No items match your search',
      ),
    );

    if (result != null) {
      setState(() => _selectedItem = result);
    }
  }
}

/// Example data model for demonstration
class ExampleItem {
  const ExampleItem({
    required this.id,
    required this.name,
    required this.category,
  });

  final int id;
  final String name;
  final String category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExampleItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Example of using Debouncer utility directly
class DebounceExample extends StatefulWidget {
  const DebounceExample({super.key});

  @override
  State<DebounceExample> createState() => _DebounceExampleState();
}

class _DebounceExampleState extends State<DebounceExample> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  String _debouncedValue = '';

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Type to see debouncing in action',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _debouncer.run(() {
              setState(() => _debouncedValue = value);
            });
          },
        ),
        const SizedBox(height: 16),
        Text('Debounced value: $_debouncedValue'),
      ],
    );
  }
}
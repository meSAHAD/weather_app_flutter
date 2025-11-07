import 'package:flutter/material.dart';

class AddCityDialog extends StatefulWidget {
  const AddCityDialog({super.key});

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add City'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter city name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final city = _controller.text.trim();
            if (city.isNotEmpty) {
              Navigator.pop(context, city);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AlertDialogWithLoading extends StatefulWidget {
  const AlertDialogWithLoading({super.key});

  @override
  _AlertDialogWithLoadingState createState() => _AlertDialogWithLoadingState();
}

class _AlertDialogWithLoadingState extends State<AlertDialogWithLoading> {
  bool _isLoading = false;

  void _performAction() async {
    setState(() {
      _isLoading = true; // Set isLoading to true before performing action
    });

    // Perform the action that requires loading
    await Future.delayed(
        const Duration(seconds: 2)); // Placeholder for the actual action

    setState(() {
      _isLoading = false; // Set isLoading to false after performing action
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Perform Action'),
      content: Column(
        children: [
          const Text('This is an example alert dialog.'),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator() // Show CircularProgressIndicator when isLoading is true
              : Container(), // Empty container when isLoading is false
        ],
      ),
      actions: [
        TextButton(
          onPressed: _performAction,
          child: const Text('Perform'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

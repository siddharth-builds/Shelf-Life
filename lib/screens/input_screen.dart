import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 1. Request OS permissions on load
    NotificationService().requestPermissions();
  }
  

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_nameController.text.trim().isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a name and expiry date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String formattedItem = "${_nameController.text.trim()} (Expires: ${_selectedDate!.toLocal().toString().split(' ')[0]})";
      
      // 2. Write to Server State
     await DatabaseService().addItem(_nameController.text, _selectedDate!);
      
      // 3. Schedule OS Notification (9:00 AM on the expiry date)
      final scheduledTime = DateTime(
        _selectedDate!.year, 
        _selectedDate!.month, 
        _selectedDate!.day, 
        9, 0 
      );

      await NotificationService().scheduleExpiryNotification(
        id: formattedItem.hashCode, // Deterministic integer mapping
        title: 'Item Expiring Today',
        body: '${_nameController.text.trim()} has reached its expiration date.',
        scheduledDate: scheduledTime,
      );

      if (mounted) Navigator.pop(context); // Return to dashboard on success
    } catch (e, stackTrace) {
      // 1. Log the error for debugging  below two lines custom to . 
      debugPrint("CRITICAL SAVE ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save item. Server rejected.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null 
                    ? 'No date selected' 
                    : 'Expiry: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveItem,
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Save Item'),
            )
          ],
        ),
      ),
    );
  }
}
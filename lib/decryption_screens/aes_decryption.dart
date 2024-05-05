import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AESDecryption extends StatefulWidget {
  const AESDecryption({Key? key});

  @override
  State<AESDecryption> createState() => _AESDecryptionState();
}

class _AESDecryptionState extends State<AESDecryption> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  String _originalMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AES Decryption'),
        backgroundColor: Color.fromARGB(255, 13, 13, 13),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Enter Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Enter Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
             SizedBox(
              width: 400,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),
                  ),
                    onPressed: _displayMessage,
                    child: Text('Decrypt Message', style: TextStyle(fontSize: 18)),
                  ),
              ),
             ),
            // SizedBox(height: 16),
            // if (_originalMessage.isNotEmpty)
            //   Text(
            //     'Original Message: $_originalMessage',
            //     style: TextStyle(fontSize: 18),
            //   ),
          ],
        ),
      ),
    );
  }

  void _displayMessage() async {
    try {
      final username = _usernameController.text;
      final password = _passwordController.text;

      // Fetch data from Firebase
      final snapshot = await _databaseReference
          .child('aes_algorithm')
          .child(username)
          .get();

      // Check if username exists
      if (!snapshot.exists) {
        _showErrorDialog('Username not found in the database.');
        return;
      }

      // Extract data from snapshot
      final data = snapshot.value as Map<dynamic, dynamic>;

      // Access the password from the data
      final storedPassword = data['password'] as String?;

      // Check if passwords match
      if (password != storedPassword) {
        _showErrorDialog('Invalid password.');
        return;
      }

      // Access the original message from the data
      final originalMessage = data['originalMessage'] as String?;
      if (originalMessage == null) {
        _showErrorDialog('Original message not found in the database.');
        return;
      }

      setState(() {
        _originalMessage = originalMessage;
      });

      // Show original message
      _showMessageDialog('Success', 'Decrypted Message: $_originalMessage');
    } catch (e) {
      _showErrorDialog('Failed to retrieve data. Error: $e');
    }
  }

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

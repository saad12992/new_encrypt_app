import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:firebase_database/firebase_database.dart';

class DigestSHA256 extends StatefulWidget {
  const DigestSHA256({super.key});

  @override
  State<DigestSHA256> createState() => _DigestSHA256State();
}

class _DigestSHA256State extends State<DigestSHA256> {
 final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Add password controller
  Uint8List? _digest;
  Duration? _encryptionTime;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHA-256 Digest Algorithm'),
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
              controller: _passwordController, // Add TextField for password
              decoration: InputDecoration(labelText: 'Enter Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                  labelText: 'Enter Amount or secret message'),
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
              onPressed: _calculateDigest,
              child: Text('Encrypt Data', style: TextStyle(fontSize: 18)),
            ),
              ),
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
                  onPressed: () {
                    Navigator.of(context).pushNamed('/digest_sha256_decryption');
                  },
                  child: Text('Decrypt Data', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateDigest() async {
    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final message =
          Uint8List.fromList(utf8.encode(_messageController.text));

      // Check if username already exists
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        // Username already exists, display message and return
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Username Exists'),
            content: Text('The username already exists in the database.'),
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
        return;
      }

      final startTime = DateTime.now();
      final digestValue = sha256Digest(message);
      final endTime = DateTime.now();

      final encryptionTime = endTime.difference(startTime);

      setState(() {
        _digest = digestValue;
        _encryptionTime = encryptionTime;
      });

      // Store the digest, encryption time, and digest key in Realtime Database
      _storeDigest(
        username,
        password, // Pass the password to store
        base64Encode(digestValue),
        encryptionTime.inMilliseconds.toString(),
        base64Encode(message), // Store digest key (message) in base64 format
        _messageController.text, // Pass the original message to store
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Failed to calculate SHA-256 digest. Please try again. Error: $e'),
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

  Uint8List sha256Digest(Uint8List data) {
    final digest = pointycastle.SHA256Digest();

    return digest.process(data);
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      final snapshot = await _databaseReference
          .child('digest_sha256_algorithm')
          .child(username)
          .once();
      return snapshot.snapshot.exists;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<void> _storeDigest(
    String username,
    String password,
    String digestBase64,
    String encryptionTimeMillis,
    String digestKeyBase64,
    String originalMessage, // Add original message parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'digest': digestBase64,
        'encryptionTime': encryptionTimeMillis,
        'digestKey': digestKeyBase64,
        'originalMessage': originalMessage, // Store the original message
        'password': password, // Store the password
      };

      await _databaseReference
          .child('digest_sha256_algorithm')
          .child(username)
          .set(data);

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHA-256 Digest: ${bin2hex(_digest!)}'),
              SizedBox(height: 8),
              Text(
                  'Encryption Time: ${_encryptionTime!.inMilliseconds} ms'),
              SizedBox(height: 8),
              Text(
                  'Original Message: $originalMessage'), // Display original message
              SizedBox(height: 8),
              Text(
                  'Encrypted message, encryption time, and original message stored successfully in the database.'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to store SHA-256 digest. Error: $e'),
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

  String bin2hex(Uint8List data) {
    return data
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
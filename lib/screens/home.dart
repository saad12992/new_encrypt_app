import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comparative Encryption Analysis'), backgroundColor: Color.fromARGB(255, 13,13,13,),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: const Text(
                  'Welcome to the Comparative Encryption Analysis App!',
              
                  style: TextStyle(fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
              ),
    
              Positioned(
                bottom: 20, // Adjust the bottom value as needed
                left: 20, // Adjust the left value as needed
                child: SizedBox(
                  width: 400, // Set the desired width
                  height: 100, // Set the desired height
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Set the desired padding
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),),
                      onPressed: () {
                        // Navigate to the AES algorithm screen
                        Navigator.of(context).pushNamed('/aes_algorithm');
                      },
                      child: Text(
                        'AES Algorithm',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Positioned(
                bottom: 20, // Adjust the bottom value as needed
                left: 20, // Adjust the left value as needed
                child: SizedBox(
                  width: 400, // Set the desired width
                  height: 100, // Set the desired height
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Set the desired padding
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),),
                      onPressed: () {
                        // Navigate to the RSA algorithm screen
                        Navigator.of(context).pushNamed('/rsa_algorithm');
                      },
                      child: Text(
                        'RSA Algorithm',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Positioned(
                bottom: 20, // Adjust the bottom value as needed
                left: 20, // Adjust the left value as needed
                child: SizedBox(
                  width: 400, // Set the desired width
                  height: 100, // Set the desired height
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Set the desired padding
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),),
                      onPressed: () {
                        // Navigate to the HMAC algorithm screen
                        Navigator.of(context).pushNamed('/hmac_algorithm');
                      },
                      child: Text(
                        'HMAC Algorithm',
                        style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              ),
              SizedBox(height: 20.0),
              Positioned(
                bottom: 20, // Adjust the bottom value as needed
                left: 20, // Adjust the left value as needed
                child: SizedBox(
                  width: 400, // Set the desired width
                  height: 100, // Set the desired height
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Set the desired padding
                    child: ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),),
                      onPressed: () {
                        // Navigate to the Digest algorithm screen
                        Navigator.of(context).pushNamed('/digest_sha256_algorithm');
                      },
                      child: Text(
                        'Digest SHA256 Algorithm',
                        style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}


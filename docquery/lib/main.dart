import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocQuery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? selectedFile;
  String question = "";
  String answer = "";
  bool isLoading = false;
  String? errorMessage;

  Future<void> pickDocument() async {
    if (selectedFile != null) {
      setState(() {
        errorMessage = null;
      });
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    } else {
      setState(() {
        errorMessage = 'No file selected.';
      });
    }
  }

  Future<void> queryModel() async {
    if (selectedFile == null || question.isEmpty) {
      setState(() {
        errorMessage = 'Please select a file and enter a question.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fileContent = await selectedFile!.readAsBytes();
      final base64FileContent = base64.encode(fileContent);

      final apiUrl = "https://api-inference.huggingface.co/models/impira/layoutlm-document-qa";
      final apiKey = "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";
      final headers = {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      };

      final payload = {
        "inputs": {
          "document": base64FileContent,
          "question": question,
        },
      };

      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: jsonEncode(payload));

      if (response.statusCode == 200) {
        final output = jsonDecode(response.body);
        setState(() {
          answer = output['answer'];
          isLoading = false;
        });
      } else {
        print("Failed to query Hugging Face API: ${response.statusCode}");
        setState(() {
          errorMessage = 'Failed to get an answer.';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        errorMessage = 'Error processing the request.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DocQuery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickDocument,
              child: Text("Pick Document"),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  question = value;
                });
              },
              decoration: InputDecoration(labelText: "Enter your question"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: queryModel,
              child: Text("Get Answer"),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (errorMessage != null)
              Text(
                "Error: $errorMessage",
                style: TextStyle(color: Colors.red),
              )
            else if (answer.isNotEmpty)
              Text(
                "Answer: $answer",
                style: TextStyle(fontSize: 16),
              )
            else
              Text("No answer yet"),
          ],
        ),
      ),
    );
  }
}

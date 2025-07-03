import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String openAiApiKey = "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";

class AIChatBot extends StatefulWidget {
  const AIChatBot({super.key});

  @override
  State<AIChatBot> createState() => _AIChatBotState();
}

class _AIChatBotState extends State<AIChatBot> {
  final TextEditingController _promptController = TextEditingController(); // Controller for input field
  String _aiResponse = ""; // Store the AI's response
  bool _isLoading = false; // To show loading indicator during API call

  // Function to send the prompt to ChatGPT API
  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true; // Show loading
    });

    final String endpoint = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo", // Specify the model
          "messages": [
            {"role": "user", "content": prompt}, // User input
          ],
          "temperature": 0.7, // Adjust randomness
          "max_tokens": 256 // Maximum tokens for the response
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Extract and show the AI response
          _aiResponse =
              data['choices'][0]['message']['content'] ?? 'No response found.';
        });
      } else {
        setState(() {
          _aiResponse =
          'Error: ${response.statusCode} ${response.reasonPhrase}';
        });
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field for the user prompt
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Type your message here...',
              ),
            ),
            const SizedBox(height: 16),
            // Send button
            ElevatedButton(
              onPressed: _isLoading
                  ? null // Disable button while loading
                  : _sendPrompt,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Send to ChatGPT'),
            ),
            const SizedBox(height: 16),
            // Display AI response
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _aiResponse,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







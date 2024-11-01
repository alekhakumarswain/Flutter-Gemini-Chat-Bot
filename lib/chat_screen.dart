import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta2/models/gemini-1.5:generateText';

  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  Future<void> fetchAIResponse(String prompt) async {
    final url = Uri.parse('$apiUrl?key=$apiKey');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "prompt": {
        "text": prompt,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String aiResponse =
            data['candidates'][0]['output'] ?? 'No response';

        setState(() {
          messages.add("You: $prompt");
          messages.add("AI: $aiResponse");
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          messages.add("Error: Unable to fetch response.");
        });
      }
    } catch (e) {
      print('Error fetching response: $e');
      setState(() {
        messages.add("Error: Unable to connect to the API.");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final prompt = _controller.text;
                    if (prompt.isNotEmpty) {
                      fetchAIResponse(prompt);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

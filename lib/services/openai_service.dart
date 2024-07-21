import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';
  
  OpenAIService(this.apiKey);

  Future<String> getOpenAIResponse(String prompt) async {
      final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $apiKey",
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
      }),
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      return decodedResponse['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response from OpenAI');
    }
  }
}
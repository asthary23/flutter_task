import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/openai_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: "dotenv.txt");
  runApp(TopState());
}

class TopState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Task',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyApp(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var formField = '';

  void updatedInput(String newValue) {
    formField = newValue;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final openAIService = OpenAIService(dotenv.env['OPENAI_API_KEY']!);
  Future<String>? _futureResponse; // Variable to hold the Future

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var input = appState.formField;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter & OpenAI Integration'),
        ),
        body: Column(
          children: [
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  onChanged: (text) {
                    appState.updatedInput(text);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ask a question',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _futureResponse = openAIService.getOpenAIResponse(input);
                });
              },
              child: SizedBox(height: 20, child: Text('Submit')),
            ),
            if (_futureResponse != null)
              FutureBuilder<String>(
                future: _futureResponse,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(
                        child:
                            Text(snapshot.data ?? 'No response from OpenAI'));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

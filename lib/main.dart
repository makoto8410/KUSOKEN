import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const TavApp());
}

class TavApp extends StatelessWidget {
  const TavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KUSOKEN TAV β',
      debugShowCheckedModeBanner: false,
      home: const TavHomePage(),
    );
  }
}

class TavHomePage extends StatefulWidget {
  const TavHomePage({super.key});

  @override
  State<TavHomePage> createState() => _TavHomePageState();
}

class _TavHomePageState extends State<TavHomePage> {
  String currentStatus = '準備';
  final List<String> logs = [];
  final String driverId = "D001";
  final String gasUrl = 'https://script.google.com/macros/s/AKfycbzns00R_lxJCCPAEHtNNWemVXitSxQWydvrfUFlX1-lji31jbPffi5nNaWlsH0XZx7E/exec';

    void addLog(String label, String event) async {
    final now = DateTime.now();

    setState(() {
      currentStatus = label;
      logs.insert(
        0,
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}  $label 送信中...',
      );
    });

    try {
      final response = await http.post(
  Uri.parse(gasUrl),
  headers: {
    'Content-Type': 'text/plain',
  },
  body: jsonEncode({
  'driverId': driverId,
  'event': event,
  'status': event,
  'source': 'Flutter',
  'note': 'button tap',
  }),
);

      setState(() {
        logs.insert(0, 'GAS送信結果：${response.statusCode}');
      });
    } catch (e) {
      setState(() {
        logs.insert(0, '送信エラー：$e');
      });
    }
  }

 Widget _buildButton(String label, String event) {
    return ElevatedButton(
     onPressed: () => addLog(label, event),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   final buttons = [
  {"label": "実車", "event": "pickup"},
  {"label": "空車", "event": "dropoff"},
  {"label": "Deploy", "event": "deploy"},
  {"label": "離脱", "event": "leave"},
  {"label": "出庫", "event": "startwork"},
  {"label": "帰庫", "event": "endwork"},
];
    return Scaffold(
      appBar: AppBar(
        title: const Text('KUSOKEN TAV β'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black12,
              ),
              child: Text(
                '現在状態：$currentStatus',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),

           GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 2.2,
  children: buttons.map((button) {
    final label = button["label"] as String;
    final event = button["event"] as String;
    return _buildButton(label, event);
  }).toList(),
),

            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ログ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(logs[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
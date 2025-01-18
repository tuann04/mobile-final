import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HieuScreen extends StatefulWidget {
  const HieuScreen({Key? key}) : super(key: key);

  @override
  _HieuScreenState createState() => _HieuScreenState();
}

class _HieuScreenState extends State<HieuScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String endpoint = "https://mullet-immortal-labrador.ngrok-free.app/health_ask";

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) {
      setState(() {
        _messages.add({"role": "bot", "text": "Tin nhắn không được để trống."});
      });
      return;
    }

    // Hiển thị tin nhắn của người dùng
    setState(() {
      _messages.add({"role": "user", "text": userMessage});
    });
    _controller.clear();

    try {
      // Gửi yêu cầu tới endpoint
      var response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(userMessage),
      );

      if (response.statusCode == 200) {
        // Parse phản hồi từ JSON và giải mã UTF-8
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        String botReply = responseData["response"] ?? "Phản hồi rỗng từ server.";
        setState(() {
          _messages.add({"role": "bot", "text": botReply});
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "text": "Lỗi server. Vui lòng thử lại sau."});
        });
      }
    } catch (e) {
      setState(() {
        String errorMessage = e.toString().substring(12, e.toString().length - 64);
        _messages.add({"role": "bot", "text": errorMessage}); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trò chuyện với Hiếu"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text("Gửi"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

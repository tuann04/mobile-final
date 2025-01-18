import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HieuScreen extends StatefulWidget {
  const HieuScreen({super.key});

  @override
  _HieuScreenState createState() => _HieuScreenState();
}

class _HieuScreenState extends State<HieuScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String endpoint =
      "https://mullet-immortal-labrador.ngrok-free.app/health_ask";

  Future<void> _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) {
      setState(() {
        _messages.add({"role": "bot", "text": "Your message is empty."});
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
        body: jsonEncode({'query': userMessage}),
      );

      if (response.statusCode == 200) {
        // Parse phản hồi từ JSON và giải mã UTF-8,
        // server return dictionary or MAP với key là 'response', value type string
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        String botReply =
            responseData["response"] ?? "Server response is empty.";
        setState(() {
          _messages.add({"role": "bot", "text": botReply});
        });
      } else {
        setState(() {
          _messages.add({"role": "bot", "text": "Internal server error."});
        });
      }
    } catch (e) {
      setState(() {
        String errorMessage = e.toString();
        _messages.add({"role": "bot", "text": errorMessage});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Personal health assistant",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  bool isUser = message['role'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: Color(0xFF00c853),
                            child: Icon(Icons.health_and_safety,
                                color: Colors.black),
                          ),
                        SizedBox(width: 10),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: isUser ? Color(0xFF00c853) : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomLeft:
                                  isUser ? Radius.circular(12) : Radius.zero,
                              bottomRight:
                                  isUser ? Radius.zero : Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Text(
                            message['text']!,
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      prefixIcon: Icon(Icons.chat, color: Color(0xFF00c853)),
                      filled: true,
                      fillColor: Colors.black54,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Color(0xFF00c853), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Color(0xFF00c853), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            BorderSide(color: Color(0xFF00c853), width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00c853),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

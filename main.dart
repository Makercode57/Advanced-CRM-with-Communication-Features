import 'package:chatphi_voip/customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:chatphi_voip/loginscreen.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:async';

// --- Chat Logic ---
class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isCustomer;
  final bool isDelivered;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isCustomer,
    this.isDelivered = true, // Mocked as always delivered
  });
}

// --- Chat Screen ---
class ChatScreen extends StatefulWidget {
  final List<ChatMessage> chatHistory;

  ChatScreen({required this.chatHistory});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = widget.chatHistory; // Pass the history when navigating to the ChatScreen
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final msg = ChatMessage(
      text: message,
      timestamp: DateTime.now(),
      isCustomer: false,
    );

    setState(() {
      _messages.add(msg);
    });

    _controller.clear();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isCustomer
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: 250),
                    decoration: BoxDecoration(
                      color: msg.isCustomer
                          ? Colors.grey.shade300
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg.text),
                        SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTimestamp(msg.timestamp),
                              style: TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "Type a message...", border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // Navigate to the Call Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CallScreen(callId: '1', chatHistory: _messages)),
              );
            },
            child: Text("Start Call"),
          ),
        ],
      ),
    );
  }
}

// --- Call Screen Logic ---
class CallScreen extends StatefulWidget {
  final String callId;
  final List<ChatMessage> chatHistory;

  CallScreen({required this.callId, required this.chatHistory});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  bool isMuted = false;
  bool isSpeaker = false;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      isSpeaker = !isSpeaker;
    });
  }

  // End the call and add it to the chat history
  void _endCall() {
    // Add a message indicating the call has ended
    final callEndMessage = ChatMessage(
      text: "Call ended",
      timestamp: DateTime.now(),
      isCustomer: false,
    );

    widget.chatHistory.add(callEndMessage); // Add this message to chat history

    // Navigate back to the chat screen with the updated chat history
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatHistory: widget.chatHistory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
           body: Column(
        children: [
          // Video display
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(_remoteRenderer), // Remote video (e.g., the person you're calling)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RTCVideoView(_localRenderer), // Local video
                  ),
                ),
              ],
            ),
          ),
          // Call control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    isMuted ? Icons.mic_off : Icons.mic,
                    color: isMuted ? Colors.red : Colors.green,
                  ),
                  onPressed: _toggleMute,
                ),
                IconButton(
                  icon: Icon(Icons.volume_up),
                  color: isSpeaker ? Colors.green : Colors.grey,
                  onPressed: _toggleSpeaker,
                ),
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red),
                  onPressed: _endCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// --- Main Screen with Bottom Navigation ---
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<ChatMessage> chatHistory = [];  // Keeps track of the chat history

  final List<Widget> _screens = [
    CustomerScreen(),     // Use CustomerScreen from customer_screen.dart
    ChatScreen(chatHistory: []), // Use ChatScreen from chat_screen.dart, initialize with an empty list
    CallScreen(callId: '1', chatHistory: []), // Call Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatPhi VOIP'),
      ),
      body: _screens[_selectedIndex], // Display the corresponding screen based on the index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'ChatPhi VOIP',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.blue),
    home: LoginScreen(),  // Starting screen with Chat
  ));
}

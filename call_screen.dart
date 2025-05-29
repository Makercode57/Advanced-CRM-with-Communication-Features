import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String callId;

  const CallScreen({Key? key, required this.callId}) : super(key: key);

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

  // End the call and return to the previous screen
  void _endCall() {
    Navigator.pop(context);  // This will return to the previous screen (ChatScreen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RTCVideoView(_remoteRenderer),  // Remote video display
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RTCVideoView(_localRenderer), // Local video display
                  ),
                ),
              ],
            ),
          ),
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
                  onPressed: _endCall,  // End the call and pop back
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

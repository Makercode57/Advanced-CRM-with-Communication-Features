class CallHistory {
  final String callId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String callerName;

  CallHistory({
    required this.callId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.callerName,
  });
}

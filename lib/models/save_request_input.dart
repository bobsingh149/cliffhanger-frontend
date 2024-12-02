class SaveRequestInput {
  final String id;
  final String requestId;

  SaveRequestInput({
    required this.id,
    required this.requestId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
  };
} 
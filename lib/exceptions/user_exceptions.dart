class UserNotFoundException implements Exception {
  final String message;
  final String userId;

  UserNotFoundException(this.userId, [this.message = 'User not found']);

  @override
  String toString() => 'UserNotFoundException: $message (userId: $userId)';
} 
class AuthRecoveryResponseModel {
  final bool success;
  final String message;
  final String? resetToken;

  const AuthRecoveryResponseModel({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory AuthRecoveryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    String? parsedResetToken;

    if (data is Map<String, dynamic>) {
      parsedResetToken = data['resetToken']?.toString();
    }

    return AuthRecoveryResponseModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      resetToken: parsedResetToken,
    );
  }
}

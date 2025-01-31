class DiagnosticResult {
  final String status;
  final String recommendation;

  DiagnosticResult({
    required this.status, 
    required this.recommendation
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      status: json['status'],
      recommendation: json['recommendation'],
    );
  }
}

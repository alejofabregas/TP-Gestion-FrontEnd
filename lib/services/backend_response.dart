class BackendResponse<T> {
  final int statusCode;
  final T body;
  final String errorMessage;
  BackendResponse({
    required this.statusCode,
    required this.body,
    required this.errorMessage,
  });
}

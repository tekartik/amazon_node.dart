/// Aws credentials.
class AwsCredentials {
  final String accessKeyId;
  final String secretAccessKey;

  AwsCredentials({required this.accessKeyId, required this.secretAccessKey});
}

class AwsSesException implements Exception {
  final String message;

  AwsSesException(this.message);

  @override
  String toString() => 'AwsSesException($message)';
}

class AwsSesMessage {
  final String from;
  final List<String>? to;
  final List<String>? cc;
  final List<String>? bcc;
  final List<String>? replyTo;
  final AwsSesContent subject;
  final AwsSesContent? text;
  final AwsSesContent? html;

  AwsSesMessage({
    required this.from,
    this.to,
    this.cc,
    this.bcc,
    required this.subject,
    this.text,
    this.html,
    this.replyTo,
  });
}

abstract class AwsSesClient {
  Future<AwsSesSendMailResult> sendMail(AwsSesMessage message);
}

abstract class AwsSes {
  /// Create new SES client.
  AwsSesClient sesClient(
      {required String region, required AwsCredentials credentials});
}

class AwsSesContent {
  static const String charsetUtf8 = 'UTF-8';
  final String charset;
  final String data;

  AwsSesContent({this.charset = charsetUtf8, required this.data});
}

class AwsSesSendMailResult {
  /// Non null means success.
  final String? messageId;

  AwsSesSendMailResult({required this.messageId});

  @override
  String toString() => 'AwsSesSendMailResult($messageId)';
}

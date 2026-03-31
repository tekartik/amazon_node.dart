import 'dart:typed_data';

/// Aws credentials.
class AwsCredentials {
  /// Access key ID.
  final String accessKeyId;

  /// Secret access key.
  final String secretAccessKey;

  /// Aws credentials.
  AwsCredentials({required this.accessKeyId, required this.secretAccessKey});
}

/// AWS SES Exception.
class AwsSesException implements Exception {
  /// Exception message.
  final String message;

  /// AWS SES Exception.
  AwsSesException(this.message);

  @override
  String toString() => 'AwsSesException($message)';
}

/// AWS SES message.
class AwsSesMessage {
  /// Sender email.
  final String from;

  /// Recipients.
  final List<String>? to;

  /// Cc.
  final List<String>? cc;

  /// Bcc.
  final List<String>? bcc;

  /// Reply-to.
  final List<String>? replyTo;

  /// Subject.
  final AwsSesContent subject;

  /// Text content.
  final AwsSesContent? text;

  /// HTML content.
  final AwsSesContent? html;

  /// Attachments.
  final List<AwsSesAttachment>? attachments;

  /// AWS SES message.
  AwsSesMessage({
    required this.from,
    this.to,
    this.cc,
    this.bcc,
    required this.subject,
    this.text,
    this.html,
    this.replyTo,
    this.attachments,
  });
}

/// AWS SES client.
abstract class AwsSesClient {
  /// Send mail.
  Future<AwsSesSendMailResult> sendMail(AwsSesMessage message);
}

/// AWS SES service.
abstract class AwsSes {
  /// Create new SES client.
  AwsSesClient sesClient({
    required String region,
    required AwsCredentials credentials,
  });
}

/// SES content.
class AwsSesContent {
  /// Default charset.
  static const String charsetUtf8 = 'UTF-8';

  /// Charset.
  final String charset;

  /// Data.
  final String data;

  /// SES content.
  AwsSesContent({this.charset = charsetUtf8, required this.data});
}

/// AWS SES send mail result.
class AwsSesSendMailResult {
  /// Non null means success.
  final String? messageId;

  /// AWS SES send mail result.
  AwsSesSendMailResult({required this.messageId});

  @override
  String toString() => 'AwsSesSendMailResult($messageId)';
}

/// SES attachment.
class AwsSesAttachment {
  /// MIME type.
  final String mimeType;

  /// Filename.
  final String filename;

  /// Content.
  final Uint8List content;

  /// SES attachment.
  AwsSesAttachment({
    required this.mimeType,
    required this.filename,
    required this.content,
  });
}

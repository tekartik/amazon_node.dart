import 'dart:typed_data';

/// AWS access key credentials used to authenticate against the SES API.
class AwsCredentials {
  /// The AWS access key ID.
  final String accessKeyId;

  /// The AWS secret access key paired with [accessKeyId].
  final String secretAccessKey;

  /// Creates credentials from an [accessKeyId] and its matching
  /// [secretAccessKey].
  AwsCredentials({required this.accessKeyId, required this.secretAccessKey});
}

/// Thrown when an AWS SES operation (such as [AwsSesClient.sendMail]) fails.
class AwsSesException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  /// Creates an exception carrying the given error [message].
  AwsSesException(this.message);

  @override
  String toString() => 'AwsSesException($message)';
}

/// An email message to send through [AwsSesClient.sendMail].
class AwsSesMessage {
  /// Sender email address.
  final String from;

  /// Recipient email addresses, or `null`/empty if there are none.
  final List<String>? to;

  /// Cc (carbon copy) recipient email addresses, or `null`/empty if there
  /// are none.
  final List<String>? cc;

  /// Bcc (blind carbon copy) recipient email addresses, or `null`/empty if
  /// there are none.
  final List<String>? bcc;

  /// Reply-to email addresses, or `null` to use [from] as the reply-to
  /// address.
  final List<String>? replyTo;

  /// Message subject line.
  final AwsSesContent subject;

  /// Plain-text body, or `null` if the message has no text part.
  final AwsSesContent? text;

  /// HTML body, or `null` if the message has no HTML part.
  final AwsSesContent? html;

  /// File attachments to include, or `null`/empty if there are none.
  final List<AwsSesAttachment>? attachments;

  /// Creates a message with the given [from] sender and [subject].
  ///
  /// [to], [cc], [bcc] and [replyTo] default to no recipients. [text] and/or
  /// [html] provide the message body; [attachments] are optional files to
  /// attach.
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

/// A client bound to a specific AWS region and set of credentials, used to
/// send email through SES. Obtain an instance via [AwsSes.sesClient].
abstract class AwsSesClient {
  /// Sends [message] through SES.
  ///
  /// Returns the [AwsSesSendMailResult] describing the outcome.
  ///
  /// Throws an [AwsSesException] if SES rejects the request.
  Future<AwsSesSendMailResult> sendMail(AwsSesMessage message);
}

/// Entry point for creating [AwsSesClient] instances. The platform-specific
/// implementation is exposed as the `awsSes` top-level getter.
abstract class AwsSes {
  /// Creates a client for sending mail through SES in the given [region]
  /// (e.g. `'us-east-1'`), authenticated using [credentials].
  AwsSesClient sesClient({
    required String region,
    required AwsCredentials credentials,
  });
}

/// A piece of text content (such as a subject line or message body) with an
/// associated character set.
class AwsSesContent {
  /// The `UTF-8` charset value, used as the default for [charset].
  static const String charsetUtf8 = 'UTF-8';

  /// Character set the [data] is encoded in.
  final String charset;

  /// The text content itself.
  final String data;

  /// Creates content from [data], encoded using [charset] (defaults to
  /// [charsetUtf8]).
  AwsSesContent({this.charset = charsetUtf8, required this.data});
}

/// The result of an [AwsSesClient.sendMail] call.
class AwsSesSendMailResult {
  /// The SES message ID assigned to the sent message when the send
  /// succeeded, or `null` if it failed.
  final String? messageId;

  /// Creates a result with the given [messageId] (`null` on failure).
  AwsSesSendMailResult({required this.messageId});

  @override
  String toString() => 'AwsSesSendMailResult($messageId)';
}

/// A file attached to an [AwsSesMessage].
class AwsSesAttachment {
  /// MIME type of [content] (e.g. `'application/pdf'`).
  final String mimeType;

  /// Name the attachment should be presented with (e.g. `'report.pdf'`).
  final String filename;

  /// Raw bytes of the attached file.
  final Uint8List content;

  /// Creates an attachment named [filename] with the given [mimeType] and
  /// raw [content] bytes.
  AwsSesAttachment({
    required this.mimeType,
    required this.filename,
    required this.content,
  });
}

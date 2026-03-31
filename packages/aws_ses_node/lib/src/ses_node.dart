import 'dart:convert';
import 'dart:js_interop';

import 'package:tekartik_aws_ses_node/src/js_interop_utils.dart';

import 'bindings.dart' as js;
import 'ses_common.dart';

export 'platform/platform.dart' show awsSes;

/// AWS SES.
class AwsSesNode implements AwsSes {
  final js.AwsSdkClientSes awsSdkClientSesJs;

  /// Create new SES client.
  @override
  AwsSesClient sesClient({
    required String region,
    required AwsCredentials credentials,
  }) {
    return AwsSesClientNode(
      this,
      awsSdkClientSesJs.sesClient(
        js.AwsSesClientOptions(
          region: region,
          credentials: js.AwsCredentials(
            accessKeyId: credentials.accessKeyId,
            secretAccessKey: credentials.secretAccessKey,
          ),
        ),
      ),
    );
  }

  AwsSesNode(this.awsSdkClientSesJs);
}

/// Client
class AwsSesClientNode implements AwsSesClient {
  final AwsSesNode awsSes;
  final js.AwsSesClient awsSesClientJs;

  AwsSesClientNode(this.awsSes, this.awsSesClientJs);

  @override
  Future<AwsSesSendMailResult> sendMail(AwsSesMessage message) async {
    try {
      if (message.attachments?.isNotEmpty ?? false) {
        return await _sendRawMail(message);
      }
      var commandJs = awsSes.awsSdkClientSesJs.sendMailCommand(
        js.AwsSesSendMailOptions(
          Destination: js.AwsSesDestination(
            ToAddresses: message.to?.stringListToJSArray(),
            CcAddresses: message.cc?.stringListToJSArray(),
            BccAddresses: message.bcc?.stringListToJSArray(),
          ),
          Message: js.AwsSesMessage(
            Body: js.AwsSesMessageBody(
              Html: message.html?.toJs(),
              Text: message.text?.toJs(),
            ),
            Subject: message.subject.toJs(),
          ),
          Source: message.from,
          ReplyToAddresses: message.replyTo?.stringListToJSArray(),
        ),
      );
      var resultJs =
          (await (awsSesClientJs.send(commandJs).toDart))
              as js.AwsSesSendMailResult;
      return AwsSesSendMailResult(messageId: resultJs.MessageId);
    } catch (e) {
      throw AwsSesException(e.toString());
    }
  }

  Future<AwsSesSendMailResult> _sendRawMail(AwsSesMessage message) async {
    var boundary = '----=_Part_${DateTime.now().millisecondsSinceEpoch}';
    var sb = StringBuffer();
    sb.writeln('From: ${message.from}');
    if (message.to?.isNotEmpty ?? false) {
      sb.writeln('To: ${message.to!.join(', ')}');
    }
    if (message.cc?.isNotEmpty ?? false) {
      sb.writeln('Cc: ${message.cc!.join(', ')}');
    }
    if (message.bcc?.isNotEmpty ?? false) {
      sb.writeln('Bcc: ${message.bcc!.join(', ')}');
    }
    if (message.replyTo?.isNotEmpty ?? false) {
      sb.writeln('Reply-To: ${message.replyTo!.join(', ')}');
    }

    // Subject with UTF-8 encoding
    var subjectBytes = utf8.encode(message.subject.data);
    var subjectEncoded = base64Encode(subjectBytes);
    sb.writeln('Subject: =?utf-8?B?$subjectEncoded?=');
    sb.writeln('MIME-Version: 1.0');
    sb.writeln('Content-Type: multipart/mixed; boundary="$boundary"');
    sb.writeln();

    // Text body
    if (message.text != null) {
      sb.writeln('--$boundary');
      sb.writeln('Content-Type: text/plain; charset=UTF-8');
      sb.writeln('Content-Transfer-Encoding: base64');
      sb.writeln();
      sb.writeln(base64Encode(utf8.encode(message.text!.data)));
    }

    // Html body
    if (message.html != null) {
      sb.writeln('--$boundary');
      sb.writeln('Content-Type: text/html; charset=UTF-8');
      sb.writeln('Content-Transfer-Encoding: base64');
      sb.writeln();
      sb.writeln(base64Encode(utf8.encode(message.html!.data)));
    }

    // Attachments
    if (message.attachments != null) {
      for (var attachment in message.attachments!) {
        sb.writeln('--$boundary');
        sb.writeln(
          'Content-Type: ${attachment.mimeType}; name="${attachment.filename}"',
        );
        sb.writeln(
          'Content-Disposition: attachment; filename="${attachment.filename}"',
        );
        sb.writeln('Content-Transfer-Encoding: base64');
        sb.writeln();
        // Insert base64 chunks
        var base64Str = base64Encode(attachment.content);
        for (var i = 0; i < base64Str.length; i += 76) {
          var end = i + 76;
          if (end > base64Str.length) {
            end = base64Str.length;
          }
          sb.writeln(base64Str.substring(i, end));
        }
      }
    }
    sb.writeln('--$boundary--');

    var rawMessageBytes = utf8.encode(sb.toString());

    var commandJs = awsSes.awsSdkClientSesJs.sendRawMailCommand(
      js.AwsSesSendRawMailOptions(
        Destinations: message.to?.stringListToJSArray(),
        Source: message.from,
        RawMessage: js.AwsSesRawMessage(Data: rawMessageBytes.toJS),
      ),
    );
    var resultJs =
        (await (awsSesClientJs.send(commandJs).toDart))
            as js.AwsSesSendMailResult;
    return AwsSesSendMailResult(messageId: resultJs.MessageId);
  }
}

extension _AwsSesContextExtPrv on AwsSesContent {
  js.AwsSesMessageContent toJs() {
    return js.AwsSesMessageContent(Charset: charset, Data: data);
  }
}

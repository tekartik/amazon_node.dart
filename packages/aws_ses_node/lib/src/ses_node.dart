import 'dart:convert';
import 'dart:js_interop';

import 'package:tekartik_aws_ses_node/src/js_interop_utils.dart';

import 'bindings.dart' as js;
import 'ses_common.dart';
import 'ses_raw_mime.dart';

export 'platform/platform.dart' show awsSes;

/// AWS SES Node.js implementation.
class AwsSesNode implements AwsSes {
  /// JS client.
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

  /// AWS SES Node.js implementation.
  AwsSesNode(this.awsSdkClientSesJs);
}

/// AWS SES Node.js client.
class AwsSesClientNode implements AwsSesClient {
  /// AWS SES Node.js implementation.
  final AwsSesNode awsSes;

  /// JS client.
  final js.AwsSesClient awsSesClientJs;

  /// AWS SES Node.js client.
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
    var rawMessageBytes = utf8.encode(
      sesRawMailMimeMessage(message, boundary: boundary),
    );

    var commandJs = awsSes.awsSdkClientSesJs.sendRawMailCommand(
      js.AwsSesSendRawMailOptions(
        Destinations: sesRawMailDestinations(message).stringListToJSArray(),
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

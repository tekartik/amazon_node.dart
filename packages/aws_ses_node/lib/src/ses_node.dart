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
  AwsSesClient sesClient(
      {required String region, required AwsCredentials credentials}) {
    return AwsSesClientNode(
        this,
        awsSdkClientSesJs.sesClient(js.AwsSesClientOptions(
            region: region,
            credentials: js.AwsCredentials(
                accessKeyId: credentials.accessKeyId,
                secretAccessKey: credentials.secretAccessKey))));
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
      var commandJs = awsSes.awsSdkClientSesJs.sendMailCommand(
          js.AwsSesSendMailOptions(
              Destination: js.AwsSesDestination(
                  ToAddresses: message.to?.stringListToJSArray(),
                  CcAddresses: message.cc?.stringListToJSArray(),
                  BccAddresses: message.bcc?.stringListToJSArray()),
              Message: js.AwsSesMessage(
                  Body: js.AwsSesMessageBody(
                      Html: message.html?.toJs(), Text: message.text?.toJs()),
                  Subject: message.subject.toJs()),
              Source: message.from,
              ReplyToAddresses: message.replyTo?.stringListToJSArray()));
      var resultJs = (await (awsSesClientJs.send(commandJs).toDart))
          as js.AwsSesSendMailResult;
      return AwsSesSendMailResult(messageId: resultJs.MessageId);
    } catch (e) {
      throw AwsSesException(e.toString());
    }
  }
}

extension _AwsSesContextExtPrv on AwsSesContent {
  js.AwsSesMessageContent toJs() {
    return js.AwsSesMessageContent(Charset: charset, Data: data);
  }
}

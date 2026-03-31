library;

// ignore_for_file: non_constant_identifier_names
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

/// AWS SDK client SES JS interop.
extension type AwsSdkClientSes._(js.JSObject _) implements js.JSObject {}

/// AWS Credentials JS interop.
extension type AwsCredentials._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS Credentials JS interop.
  external factory AwsCredentials({String accessKeyId, String secretAccessKey});
}

/// AWS SES Client options JS interop.
extension type AwsSesClientOptions._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Client options JS interop.
  external factory AwsSesClientOptions({
    String region,
    AwsCredentials credentials,
  });
}

/// AWS SES Client options extension JS interop.
extension AwsSesClientOptionsExt on AwsSesClientOptions {
  /// Region.
  external String get region;
}

/// AWS SES Client JS interop.
extension type AwsSesClient._(js.JSObject _) implements js.JSObject {}

/// AWS SES Client extension JS interop.
extension AwsSesClientExt on AwsSesClient {
  /// Send command.
  external js.JSPromise<js.JSObject> send(js.JSObject command);
}

/// AWS SES Send mail result JS interop.
extension type AwsSesSendMailResult._(js.JSObject _) implements js.JSObject {}

/// AWS SES Send mail result extension JS interop.
extension AwsSesSendMailResultExt on AwsSesSendMailResult {
  /// Message ID.
  external String get MessageId;
}

/// AWS SES Send mail command JS interop.
extension type AwsSesSendMailCommand._(js.JSObject _) implements js.JSObject {}

/// AWS SDK client SES extension JS interop.
extension AwsSdkClientSesExt on AwsSdkClientSes {
  /// SES client constructor.
  external js.JSFunction get SESClient;

  /// Send email command constructor.
  external js.JSFunction get SendEmailCommand;

  /// Send raw email command constructor.
  external js.JSFunction get SendRawEmailCommand;

  /// Create SES client.
  AwsSesClient sesClient(AwsSesClientOptions options) {
    return SESClient.callAsConstructor(options);
  }

  /// Create send mail command.
  AwsSesSendMailCommand sendMailCommand(AwsSesSendMailOptions options) {
    return SendEmailCommand.callAsConstructor(options);
  }

  /// Create send raw mail command.
  AwsSesSendRawMailCommand sendRawMailCommand(
    AwsSesSendRawMailOptions options,
  ) {
    return SendRawEmailCommand.callAsConstructor(options);
  }
}

/// AWS SES Send raw mail command JS interop.
extension type AwsSesSendRawMailCommand._(js.JSObject _)
    implements js.JSObject {}

/// AWS SES Raw message JS interop.
extension type AwsSesRawMessage._(js.JSObject _) implements js.JSObject {
  /// AWS SES Raw message JS interop.
  external factory AwsSesRawMessage({js.JSUint8Array Data});
}

/// AWS SES Send raw mail options JS interop.
extension type AwsSesSendRawMailOptions._(js.JSObject _)
    implements js.JSObject {
  /// AWS SES Send raw mail options JS interop.
  external factory AwsSesSendRawMailOptions({
    js.JSArray<js.JSString>? Destinations,
    String? Source,
    AwsSesRawMessage RawMessage,
  });
}

/// AWS SES Destination JS interop.
extension type AwsSesDestination._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Destination JS interop.
  external factory AwsSesDestination({
    js.JSArray<js.JSString>? ToAddresses,
    js.JSArray<js.JSString>? CcAddresses,
    js.JSArray<js.JSString>? BccAddresses,
  });
}

/// AWS SES Message JS interop.
extension type AwsSesMessage._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Message JS interop.
  external factory AwsSesMessage({
    AwsSesMessageBody Body,
    AwsSesMessageContent Subject,
  });
}

/// AWS SES Message body JS interop.
extension type AwsSesMessageBody._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Message body JS interop.
  external factory AwsSesMessageBody({
    AwsSesMessageContent? Html,
    AwsSesMessageContent? Text,
  });
}

/// AWS SES Message content JS interop.
extension type AwsSesMessageContent._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Message content JS interop.
  external factory AwsSesMessageContent({String Charset, String Data});
}

/// AWS SES Send mail options JS interop.
extension type AwsSesSendMailOptions._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  /// AWS SES Send mail options JS interop.
  external factory AwsSesSendMailOptions({
    AwsSesDestination Destination,
    AwsSesMessage Message,
    String Source,
    js.JSArray<js.JSString>? ReplyToAddresses,
  });
}

//  Destination: {
//       /* required */
//       CcAddresses: [
//         /* more items */
//       ],
//       ToAddresses: [
//         toAddress,
//         /* more To-email addresses */
//       ],
//     },
//     Message: {
//       /* required */
//       Body: {
//         /* required */
//         Html: {
//           Charset: "UTF-8",
//           Data: "HTML_FORMAT_BODY",
//         },
//         Text: {
//           Charset: "UTF-8",
//           Data: "TEXT_FORMAT_BODY",
//         },
//       },
//       Subject: {
//         Charset: "UTF-8",
//         Data: "EMAIL_SUBJECT",
//       },
//     },
//     Source: fromAddress,
//     ReplyToAddresses: [
//       /* more items */
//     ],
//     },

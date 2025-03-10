library;

// ignore_for_file: non_constant_identifier_names
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js;

extension type AwsSdkClientSes._(js.JSObject _) implements js.JSObject {}

extension type AwsCredentials._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsCredentials({String accessKeyId, String secretAccessKey});
}

extension type AwsSesClientOptions._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesClientOptions({
    String region,
    AwsCredentials credentials,
  });
}

extension AwsSesClientOptionsExt on AwsSesClientOptions {
  external String get region;
}

extension type AwsSesClient._(js.JSObject _) implements js.JSObject {}

extension AwsSesClientExt on AwsSesClient {
  external js.JSPromise<js.JSObject> send(AwsSesSendMailCommand command);
}

extension type AwsSesSendMailResult._(js.JSObject _) implements js.JSObject {}

extension AwsSesSendMailResultExt on AwsSesSendMailResult {
  external String get MessageId;
}

extension type AwsSesSendMailCommand._(js.JSObject _) implements js.JSObject {}

extension AwsSdkClientSesExt on AwsSdkClientSes {
  external js.JSFunction get SESClient;
  external js.JSFunction get SendEmailCommand;

  AwsSesClient sesClient(AwsSesClientOptions options) {
    return SESClient.callAsConstructor(options);
  }

  AwsSesSendMailCommand sendMailCommand(AwsSesSendMailOptions options) {
    return SendEmailCommand.callAsConstructor(options);
  }
}

extension type AwsSesDestination._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesDestination({
    js.JSArray<js.JSString>? ToAddresses,
    js.JSArray<js.JSString>? CcAddresses,
    js.JSArray<js.JSString>? BccAddresses,
  });
}

extension type AwsSesMessage._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessage({
    AwsSesMessageBody Body,
    AwsSesMessageContent Subject,
  });
}

extension type AwsSesMessageBody._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessageBody({
    AwsSesMessageContent? Html,
    AwsSesMessageContent? Text,
  });
}

extension type AwsSesMessageContent._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
  external factory AwsSesMessageContent({String Charset, String Data});
}

extension type AwsSesSendMailOptions._(js.JSObject _) implements js.JSObject {
  // Must have an unnamed factory constructor with named arguments.
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

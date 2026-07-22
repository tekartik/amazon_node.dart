import 'package:tekartik_aws_ses_node/src/aws_node_js.dart';
import 'package:tekartik_aws_ses_node/src/ses_node.dart';

/// The [AwsSes] entry point for this platform (Node.js), backed by the AWS
/// SDK's SES client. Call [AwsSes.sesClient] on it to obtain an
/// [AwsSesClient] for sending mail.
final awsSes = AwsSesNode(awsClientSesNodeJs);

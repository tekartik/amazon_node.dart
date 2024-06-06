import 'package:node_interop/node.dart';
import 'package:node_interop/node_interop.dart';
import 'bindings_legacy.dart' as js;

final awsClientSesNodeJs = require('@aws-sdk/client-ses') as js.AwsSdkClientSes;

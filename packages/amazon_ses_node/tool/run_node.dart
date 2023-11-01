import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();
  await shell.run('''
node build/example/main.dart.js
  ''');
}

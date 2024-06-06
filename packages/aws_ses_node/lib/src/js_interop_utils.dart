import 'dart:js_interop' as js;

extension AmazonNoeListStringJsExt on List<String> {
  js.JSArray<js.JSString> stringListToJSArray() {
    return map((e) => e.toJS).toList().toJS;
  }
}

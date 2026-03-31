import 'dart:js_interop' as js;

/// JS interop utilities.
extension AmazonNoeListStringJsExt on List<String> {
  /// Convert list of string to JS array.
  js.JSArray<js.JSString> stringListToJSArray() {
    return map((e) => e.toJS).toList().toJS;
  }
}

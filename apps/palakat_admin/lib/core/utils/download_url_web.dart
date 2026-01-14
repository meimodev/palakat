import 'dart:js_interop';

@JS('document')
external Document get _document;

@JS()
extension type Document(JSObject _) implements JSObject {
  external HTMLElement? get body;

  external JSObject createElement(String tagName);
}

@JS()
extension type HTMLElement(JSObject _) implements JSObject {
  external JSAny? appendChild(JSObject node);
}

@JS()
extension type HTMLAnchorElement(JSObject _) implements JSObject {
  external set href(String value);

  external set download(String value);

  external void click();

  external void remove();
}

Future<void> triggerBrowserDownload(Uri uri, {String? filename}) async {
  final body = _document.body;
  if (body == null) return;
  final anchor = HTMLAnchorElement(_document.createElement('a'));
  anchor.href = uri.toString();
  if (filename != null && filename.isNotEmpty) {
    anchor.download = filename;
  }
  body.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

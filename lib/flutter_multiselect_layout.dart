import 'package:flutter/material.dart';
import './flutter_multiselect_render_layout_box.dart';
import './flutter_multiselect_layout_delegate.dart';

/// This is just a normal [CustomMultiChildLayout] with
/// overrided [createRenderObject] to use custom [RenderCustomMultiChildLayoutBox]
class FlutterMultiselectLayout extends CustomMultiChildLayout {
  FlutterMultiselectLayout({
    required FlutterMultiselectLayoutDelegate delegate,
    Key? key,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children, delegate: delegate);

  @override
  FlutterMultiselectRenderLayoutBox createRenderObject(BuildContext context) {
    return FlutterMultiselectRenderLayoutBox(
        delegate: delegate as FlutterMultiselectLayoutDelegate);
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This is the layout delegate that is used to layout the tags and the text field.
/// It is used in [FlutterMultiselectLayout]
class FlutterMultiselectLayoutDelegate extends MultiChildLayoutDelegate {
  FlutterMultiselectLayoutDelegate(
      {required this.length,
      required this.minTextFieldWidth,
      required this.spacing,
      required this.position});

  final Offset position;

  static const tagId = 'tag_';
  static const textFieldId = 'text_field';
  static const textId = 'text_id';

  final int length;
  final double minTextFieldWidth;
  final double spacing;

  /// This is used for
  Size parentSize = Size.zero;

  static String getTagId(int id) {
    return '$tagId$id';
  }

  static bool _isOverflow({
    required double childWidth,
    required double parentWidth,
    required List<Size> tagSizes,
    required double spacing,
  }) {
    final tagsWidth = tagSizes.fold<double>(0, (result, tag) {
      return result + tag.width;
    });
    final spacingWidth = spacing * max(tagSizes.length - 1, 0);

    return childWidth + tagsWidth + spacingWidth > parentWidth;
  }

  @override
  Size getSize(BoxConstraints constraints) {
    // * Just putting in 0 to avoid the assert error
    return Size(constraints.maxWidth, 0);
  }

  @override
  void performLayout(Size size) {
    var cursor = Offset.zero;
    var tagSizes = <Size>[];
    //* Layout all the tags here
    for (final index in Iterable<int>.generate(length).toList()) {
      final tagId = getTagId(index);
      if (hasChild(getTagId(index))) {
        final childSize = layoutChild(
          tagId,
          BoxConstraints.loose(
            //* Let child specify it's own heigh so use infinity here
            Size(size.width, double.infinity),
          ),
        );

        //* Check if overflowing
        if (_isOverflow(
          childWidth: childSize.width,
          parentWidth: size.width,
          tagSizes: tagSizes,
          spacing: spacing,
        )) {
          //* Push the cursor down and back to the left
          cursor = Offset(0, (length > 0 ? cursor.dy : 0) + childSize.height);

          //* Reset the tagSizes for this roll
          tagSizes = <Size>[];
        }

        positionChild(tagId, cursor);
        // * Update cursor to the next position
        cursor = Offset(cursor.dx + childSize.width + spacing, cursor.dy);
        // * Push the size to tagSizes
        tagSizes.add(childSize);
      }
    }

    var textFieldSize = Size.zero;

    //* Layout the TextBox
    if (hasChild(textFieldId)) {
      final currentRowWidth = tagSizes.fold<double>(0, (result, tag) {
        return result + tag.width;
      });
      final spacingWidth = spacing * max(tagSizes.length - 1, 0);
      final leftOverWidth = size.width - currentRowWidth - spacingWidth;
      final textWidth = max(leftOverWidth, minTextFieldWidth);
      //* Check if TextBox is overflowing
      //* Check if overflowing
      if (_isOverflow(
        childWidth: textWidth,
        parentWidth: size.width,
        tagSizes: tagSizes,
        spacing: spacing,
      )) {
        textFieldSize = layoutChild(
          textFieldId,
          BoxConstraints.loose(Size.fromWidth(size.width)),
        );
        //* Push the cursor down and back to the left
        cursor =
            Offset(0, (length > 0 ? (cursor.dy + textFieldSize.height) : 0));

        //* Reset the tagSizes for this roll
        tagSizes = <Size>[];
      } else {
        textFieldSize = layoutChild(
          textFieldId,
          BoxConstraints.loose(Size.fromWidth(textWidth)),
        );
      }
      positionChild(textFieldId, cursor);
    }

    //* Set parent height so that [TagsRenderLayoutBox] can use it to set the parentHeight
    parentSize =
        Size(size.width, (length > 0 ? cursor.dy : 0) + textFieldSize.height);
  }

  @override
  bool shouldRelayout(FlutterMultiselectLayoutDelegate oldDelegate) {
    return oldDelegate.position != position;
  }
}

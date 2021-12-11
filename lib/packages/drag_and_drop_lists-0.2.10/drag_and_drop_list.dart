import 'package:get/get.dart';

import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_item.dart';
import 'drag_and_drop_item_target.dart';
import 'drag_and_drop_item_wrapper.dart';
import 'drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragAndDropList implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget header;

  /// The widget that is displayed at the bottom of the list.
  final Widget footer;

  /// The widget that is displayed to the left of the list.
  final Widget leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  // ignore: deprecated_member_use
  final List<DragAndDropItem> children = List<DragAndDropItem>();

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;

  //Bao custom
  //Enable thêm thẻ mới
  bool enableAddNew;

  //Bao custom
  //Lưu id để thay đổi trạng thái enable
  final String keyAddress;

  //Controller của List children
  final ScrollController scrollController;

  // Vị trí trong Task trong Project
  final int index;

  DragAndDropList(
      {List<DragAndDropItem> children,
      this.header,
      this.footer,
      this.leftSide,
      this.rightSide,
      this.contentsWhenEmpty,
      this.lastTarget,
      this.decoration,
      this.horizontalAlignment = MainAxisAlignment.start,
      this.verticalAlignment = CrossAxisAlignment.start,
      this.enableAddNew = false,
      this.keyAddress,
      this.index,
      this.scrollController,
      this.canDrag = true
      
      }) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    List<Widget> contents = [];
    // if (header != null) {
    //   contents.add(Flexible(child: header));
    // }
    Widget intrinsicHeight = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: horizontalAlignment,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateDragAndDropListInnerContents(params),
      ),
    );
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = Container(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.listInnerDecoration != null) {
      intrinsicHeight = Container(
        decoration: params.listInnerDecoration,
        child: intrinsicHeight,
      );
    }
    contents.add(intrinsicHeight);

    // if (footer != null) {
    //   contents.add(Flexible(child: footer));
    // }

    return Container(
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding.horizontal,
      decoration: decoration ?? params.listDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: verticalAlignment,
        children: [
          Flexible(child: header),
          // DragChildrenList(contents: headerName == CardDemoModel.listHeader.first ? contents),
          Container(
            constraints:
                BoxConstraints(minHeight: 10, maxHeight: Get.height * 0.6),
            child: ListView(
                controller: params.listChildrenScrollController[index] ??
                    ScrollController(),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: contents),
          ),
          Flexible(child: footer)
        ],
      ),
    );
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters params) {
    var contents = List<Widget>();
    if (leftSide != null) {
      contents.add(leftSide);
    }
    if (children != null && children.isNotEmpty) {
      List<Widget> allChildren = List<Widget>();
      if (params.addLastItemTargetHeightToTop) {
        allChildren.add(Padding(
          padding: EdgeInsets.only(top: params.lastItemTargetHeight),
        ));
      }
      for (int i = 0; i < children.length; i++) {
        allChildren.add(DragAndDropItemWrapper(
          child: children[i],
          parameters: params,
        ));
        if (params.itemDivider != null && i < children.length - 1) {
          allChildren.add(params.itemDivider);
        }
      }
      allChildren.add(DragAndDropItemTarget(
        parent: this,
        parameters: params,
        onReorderOrAdd: params.onItemDropOnLastTarget,
        child: lastTarget ??
            Container(
              height: params.lastItemTargetHeight,
            ),
      ));
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: verticalAlignment,
              mainAxisSize: MainAxisSize.max,
              children: allChildren,
            ),
          ),
        ),
      );
    } else {
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                contentsWhenEmpty ??
                    Text(
                      'Empty list',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                DragAndDropItemTarget(
                  parent: this,
                  parameters: params,
                  onReorderOrAdd: params.onItemDropOnLastTarget,
                  child: lastTarget ??
                      Container(
                        height: params.lastItemTargetHeight,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (rightSide != null) {
      contents.add(rightSide);
    }
    return contents;
  }
}

// class DragChildrenList extends StatefulWidget {
//   final List<Widget> contents;
//   DragChildrenList({Key key, this.contents}) : super(key: key);

//   @override
//   _DragChildrenListState createState() => _DragChildrenListState();
// }

// class _DragChildrenListState extends State<DragChildrenList> {
//   ScrollController scrollController;

//   @override
//   void initState() {
//     super.initState();
//     scrollController = ScrollController();

//     scrollController.addListener(() {
//       print("scrollController.offset ${scrollController.offset}");
//     });
//   }

//   @override
//   void dispose() {
//     scrollController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(minHeight: 120, maxHeight: Get.height * 0.65),
//       child: ListView(
//           controller: scrollController ?? ScrollController(),
//           shrinkWrap: true,
//           physics: AlwaysScrollableScrollPhysics(),
//           children: widget.contents),
//     );
//   }
// }

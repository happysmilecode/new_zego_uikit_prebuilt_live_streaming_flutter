// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoEffectGridItem<T> {
  String id;
  T effectType;

  ButtonIcon icon;
  ButtonIcon? selectIcon;
  String iconText;
  VoidCallback onPressed;

  ZegoEffectGridItem({
    required this.id,
    required this.effectType,
    required this.icon,
    required this.iconText,
    required this.onPressed,
    this.selectIcon,
  });
}

/// @nodoc
class ZegoEffectGridModel {
  String title;

  ValueNotifier<String> selectedID;
  List<ZegoEffectGridItem> items = [];

  ZegoEffectGridModel({
    required this.title,
    required this.items,
    required this.selectedID,
  });
}

/// @nodoc
class ZegoEffectGrid extends StatefulWidget {
  const ZegoEffectGrid({
    Key? key,
    required this.model,
    required this.isSpaceEvenly,
    this.buttonSize,
    this.iconSize,
    this.withBorderColor = false,
    this.itemSpacing,
  }) : super(key: key);

  final ZegoEffectGridModel model;
  final bool withBorderColor;
  final Size? buttonSize;
  final Size? iconSize;
  final bool isSpaceEvenly;
  final double? itemSpacing;

  @override
  State<ZegoEffectGrid> createState() => _ZegoEffectGridState();
}

/// @nodoc
class _ZegoEffectGridState extends State<ZegoEffectGrid> {
  TextStyle get gridItemTextStyle => TextStyle(
        fontSize: 24.zR,
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.zR,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          line(),
          SizedBox(
            height: 133.zR,
            child: grid(),
          )
        ],
      ),
    );
  }

  Widget header() {
    return widget.model.title.isEmpty
        ? Container()
        : Text(
            widget.model.title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26.zR,
              color: Colors.white,
            ),
          );
  }

  Widget line() {
    return widget.model.title.isEmpty ? Container() : SizedBox(height: 30.zR);
  }

  Widget grid() {
    if (widget.isSpaceEvenly) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.model.items.map((item) {
          return gridItem(item, widget.buttonSize ?? Size(88.zR, 133.zR));
        }).toList(),
      );
    }

    return CustomScrollView(
      scrollDirection: Axis.horizontal,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: widget.model.items
                .map((item) {
                  var buttonSize = widget.buttonSize ?? Size(88.zR, 133.zR);
                  final bestButtonWidth =
                      getTextSize(item.iconText, gridItemTextStyle).width;
                  buttonSize = Size(
                    bestButtonWidth + 20.zR,
                    buttonSize.height,
                  );
                  return gridItem(item, buttonSize);
                })
                .map((item) => Row(
                      children: [
                        item,
                        Container(width: widget.itemSpacing ?? 40.zR)
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget gridItem(ZegoEffectGridItem item, Size buttonSize) {
    return ZegoTextIconButton(
      onPressed: () {
        widget.model.selectedID.value = item.id;
        item.onPressed.call();

        setState(() {}); //  todo
      },
      buttonSize: buttonSize,
      iconSize: widget.iconSize ?? Size(72.zR, 72.zR),
      iconTextSpacing: 12.zR,
      icon: item.id == widget.model.selectedID.value
          ? (item.selectIcon ?? item.icon)
          : item.icon,
      iconBorderColor: widget.withBorderColor
          ? (item.id == widget.model.selectedID.value
              ? const Color(0xffA653FF)
              : Colors.transparent)
          : Colors.transparent,
      text: item.iconText,
      textStyle: TextStyle(
        color: item.id == widget.model.selectedID.value
            ? const Color(0xffA653FF)
            : const Color(0xffCCCCCC),
        fontSize: 24.zR,
        fontWeight: FontWeight.w500,
      ),
      softWrap: false,
    );
  }
}

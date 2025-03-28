import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

// ignore: must_be_immutable
class CircleListItem extends StatefulWidget {
  CircleListItem({
    super.key,
    this.onTap,
    this.title = "",
    this.icon,
    this.isSelected = false,
  });

  final Function? onTap;
  bool isSelected;
  final String title;
  final IconData? icon;
  @override
  State<StatefulWidget> createState() => _CircleListItemState();
}

class _CircleListItemState extends State<CircleListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
        // setState(() {
        //   widget.isSelected = true;
        // });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Icon(
                  widget.icon ?? Icons.attach_money_outlined,
                  color: widget.isSelected
                      ? SilentiColors.primary
                      : SilentiColors.gray,
                ),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Container(
              width: 54,
              alignment: Alignment.center,
              child: Text(
                widget.title,
                overflow: TextOverflow.fade,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isSelected
                      ? SilentiColors.secondary
                      : SilentiColors.gray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

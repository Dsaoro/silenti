import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';

class ResumeCard extends StatefulWidget {
  const ResumeCard(
      {super.key,
      required this.children,
      this.background = SilentiColors.gray});

  final List<Widget> children;
  final Color background;

  @override
  State<ResumeCard> createState() => _ResumeCardState();
}

Widget _emptyWidgetResponse = SizedBox(
  height: double.infinity,
  width: double.infinity,
  child: Center(
    child: Text(
      "There is no available data",
      overflow: TextOverflow.visible,
      maxLines: 2,
    ),
  ),
);

class _ResumeCardState extends State<ResumeCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: widget.children.isEmpty
          ? _emptyWidgetResponse
          : ListView(
              scrollDirection: Axis.vertical,
              children: widget.children,
            ),
    );
  }
}

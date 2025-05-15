import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:flutter/material.dart';

class NamedDetailsRow extends StatelessWidget {
  const NamedDetailsRow({super.key, required this.name, required this.item, this.isEven = true});
  final String name;
  final String item;
  final bool isEven;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : tertiaryColor,
      width: 290,
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              name,
            ),
          ),
          SizedBox(
            width: 150,
            height: 30,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

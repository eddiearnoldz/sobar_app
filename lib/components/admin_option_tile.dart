import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AdminOptionTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color color;
  final VoidCallback onTap;

  const AdminOptionTile({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Anton',
            fontSize: 25,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.1,
          ),
        ),
        trailing: SvgPicture.asset(
          iconPath,
          color: Theme.of(context).colorScheme.onPrimary,
          width: 35,
          height: 35,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    );
  }
}

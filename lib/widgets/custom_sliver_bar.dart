// import 'package:fiufit/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CustomFoldableAppBar extends StatelessWidget {
  final String? title;
  final String? asset;
  final double expandedHeight;

  const CustomFoldableAppBar({
    super.key,
    this.title,
    this.asset,
    required this.expandedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: expandedHeight,
      floating: false,
      pinned: false,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            padding: const EdgeInsets.only(left: 10),
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            color: Colors.black12,
            child: title != null
                ? Text(
                    title!,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                : null,
          ),
          background: FadeInImage(
            placeholder: const AssetImage('assets/jar-loading.gif'),
            image: asset != null
                ? AssetImage(asset!)
                : const AssetImage('assets/no-image-found.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

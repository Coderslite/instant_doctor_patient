import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';

import '../../constant/color.dart';

class ImagePreview extends StatefulWidget {
  final String imageUrl;
  const ImagePreview({super.key, required this.imageUrl});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        title: Text(
          "Preview",
          style: primaryTextStyle(color: kPrimary),
        ),
        leading: const BackButton(
          color: kPrimary,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: kPrimary,
            image: DecorationImage(
              image: AssetImage("assets/images/particle.png"),
              fit: BoxFit.cover,
              opacity: 0.4,
            )),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PhotoView(
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  imageProvider: CachedNetworkImageProvider(widget.imageUrl),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

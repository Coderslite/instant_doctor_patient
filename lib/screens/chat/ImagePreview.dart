import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_view/photo_view.dart';

import '../../component/backButton.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          color: kPrimary,
          image: DecorationImage(
            image: AssetImage("assets/images/particle.png"),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 20, left: 20),
                child: Row(
                  children: [
                    backButton(context),
                    Text(
                      "Back",
                      style: boldTextStyle(
                        size: 14,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained,
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

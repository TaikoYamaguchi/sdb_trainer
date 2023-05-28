import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer(this.url, {Key? key}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            GestureDetector(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 4.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: ZoomOverlay(
                          modalBarrierColor: Colors.black12, // optional
                          minScale: 0.5, // optional
                          maxScale: 3.0, // optional
                          twoTouchOnly: true,
                          animationDuration: const Duration(milliseconds: 300),
                          animationCurve: Curves.fastOutSlowIn,
                          onScaleStop: () {},
                          child: CachedNetworkImage(imageUrl: url),
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}

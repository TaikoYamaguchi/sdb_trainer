import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer(this.url, {Key? key}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: CachedNetworkImage(
                  imageUrl: url,
                  imageBuilder: (context, imageProivder) => InteractiveViewer(
                        panEnabled:
                            false, // Set it to false to prevent panning.
                        boundaryMargin: EdgeInsets.all(80),
                        minScale: 1,
                        maxScale: 4,
                        child: Center(
                          child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: imageProivder,
                                  fit: BoxFit.cover,
                                )),
                              )),
                        ),
                      )),
              onTap: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

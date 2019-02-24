import 'package:flutter/material.dart';

typedef AvatarTapCallback = void Function();

class AvatarImageButton extends StatelessWidget {
  AvatarImageButton({Key key, @required this.height, 
      @required this.width , this.onTap,
      @required this.image })
      : assert(height != null),
        assert(width != null),
        assert(image != null),
        super(key: key);

  final AvatarTapCallback onTap;
  final double width;
  final double height;
  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        child: InkWell(
          onTap: () { onTap(); }
        ),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
                fit: BoxFit.cover,
                image: image
            )
        )
    );
  }
}

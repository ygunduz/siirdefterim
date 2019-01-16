import 'package:flutter/material.dart';

typedef ButtonTapCallback = void Function();

class CustomButton extends StatelessWidget {
  CustomButton({Key key, @required this.height, 
      @required this.width , @required this.onTap,
      @required this.borderRadius , @required this.text,
      @required this.textSize , @required this.color, 
      @required this.textColor})
      : assert(height != null),
        assert(width != null),
        assert(onTap != null),
        assert(borderRadius != null),
        assert(text != null),
        assert(textSize != null),
        assert(color != null),
        assert(textColor != null),
        super(key: key);

  final double height;
  final double width;
  final double borderRadius;
  final double textSize;
  final String text;
  final Color color;
  final Color textColor;
  final ButtonTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius), color: color),
        child: InkWell(
          onTap: () {
            onTap();
          },
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(text, style: TextStyle(fontSize: textSize , color: textColor)),
            ],
          )),
        ),
      ),
    );
  }
}

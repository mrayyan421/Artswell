import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import '../../utils/constants/size.dart';

class FormStyling extends StatefulWidget {
  const FormStyling({
    super.key,
    required this.img,
    required this.placeholderText,
    required this.controller,
    required this.validator,
    this.password = false,
    this.isNumber=true
  });

  final String img;
  final String placeholderText;
  final bool password;
  final bool isNumber;
  final TextEditingController controller;
  final FormFieldValidator validator;

  @override
  State<FormStyling> createState() => _FormStylingState();
}

class _FormStylingState extends State<FormStyling> {
  late bool _obscureText;
  late bool _isNumber;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.password;
  }
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(kSizes.smallPadding),
          child: Image.asset(
            widget.img,
            color: kColorConstants.klDividerColor,
            width: kSizes.smallIcon,
          ),
        ),
        suffixIcon: widget.password
            ? GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Padding(
            padding: const EdgeInsets.all(kSizes.smallPadding),
            child: Image.asset(
              _obscureText
                  ? 'assets/icons/hidePassword.png'
                  : 'assets/icons/showPassword.png',
              width: kSizes.smallIcon,
              color: kColorConstants.klDividerColor,
            ),
          ),
        )
            : null,
        labelText: widget.placeholderText,
        labelStyle: const TextStyle(
          fontFamily: 'assets/fonts/Poppins/Poppins-ThinItalic',fontSize: kSizes.gridViewSpace,color: Colors.black
        ),
      ),
    );
  }
}

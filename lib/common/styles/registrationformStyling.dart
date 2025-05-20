import 'package:artswellfyp/utils/constants/colorConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants/size.dart';

class FormStylingRegistrationScreen extends StatefulWidget {
  const FormStylingRegistrationScreen({
    super.key,
    required this.img,
    required this.placeholderText,
    // this.
    this.password = false,
    this.isNumber=true,
    this.keyboardLayout,
    this.textEditingController,
    this.validator
  });

  final TextEditingController? textEditingController;
  final FormFieldValidator? validator;
  final String img;
  final String placeholderText;
  final bool password;
  final bool isNumber;
  final Brightness? keyboardLayout;

  @override
  State<FormStylingRegistrationScreen> createState() =>
      _FormStylingRegistrationScreenState();
}
class _FormStylingRegistrationScreenState extends State<FormStylingRegistrationScreen> {
  late bool _obscureText;

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
      validator: widget.validator,
      controller: widget.textEditingController,
      obscureText: _obscureText,
      keyboardType: widget.isNumber?TextInputType.number:TextInputType.text,inputFormatters: widget.isNumber?<TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]:null,
      keyboardAppearance: widget.keyboardLayout,
      style: const TextStyle(
        color: Colors.black,
        fontFamily: 'assets/fonts/Poppins/Poppins-Regular',
        fontSize: kSizes.gridViewSpace,
      ),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: kColorConstants.klDividerColor, width: 1.0),
          borderRadius: BorderRadius.circular(kSizes.smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: kColorConstants.klPrimaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(kSizes.smallBorderRadius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(kSizes.smallBorderRadius),
        ),
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
          fontFamily: 'assets/fonts/Poppins/Poppins-ThinItalic',
          fontSize: kSizes.gridViewSpace,
          color: Colors.black54,
        ),
      ),
    );
  }
}
class ElevationButtonRegistrationStyling {
  static ButtonStyle elevatedButtonStyle({required bool isSelected}) {
    return ElevatedButton.styleFrom(
      backgroundColor: !isSelected
          ? kColorConstants.klSecondaryColor
          : kColorConstants.klOrangeColor,
      minimumSize: const Size(120, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: isSelected?5.0:2.0
    );
  }
}
class RoleSelectionButton extends StatelessWidget {
  final String role;
  final String selectedRole;
  final VoidCallback onPressed;

  const RoleSelectionButton({
    super.key,
    required this.role,
    required this.selectedRole,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevationButtonRegistrationStyling.elevatedButtonStyle(
        isSelected: role == selectedRole,
      ),
      child: Text(role),
    );}}


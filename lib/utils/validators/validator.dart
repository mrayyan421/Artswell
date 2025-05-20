
/*class kCredentialValidators{//email validation functions
  final _emailRegularExpression=RegExp(r'^[a-zA-Z0-9._%+#$-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'); //fyp219@gmail.com
  final _passwordRegularExpression=RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,}$'); //Password123!
  static String? validateEmail(String? email){
    final regExEmail= kCredentialValidators()._emailRegularExpression;
    if(email==null || email.isEmpty){
      return 'Email required';
    }else if(!regExEmail.hasMatch(email)){
      return 'Invalid email address';
    }final String domain=email.split('@').last;
    if(!kConstantVariables().validDomains.contains(domain)){
      return 'Invalid domain';
    }else{
      return null;
    }
  }
  static String? validatePassword(String? password) {
    final regExPassword = kCredentialValidators()._passwordRegularExpression;
    if(password==null || password.isEmpty){
      return 'Enter Password';
    }else if(!regExPassword.hasMatch(password)){
      return 'Invalid password';
    }else{
      return null;
    }
  }
}*/
//TODO: class for defining multiple RegEx(s) for validation purposes

class kValidator {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '';//as some artisans might have google account and some might not->for them register through phone number
    }

    // 11 digit phonenum regex
    final phoneRegExp = RegExp(r'^\d{11}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (11 digits required).';
    }

    return null;
  }
}
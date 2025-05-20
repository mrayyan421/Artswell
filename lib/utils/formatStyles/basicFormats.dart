import 'package:intl/intl.dart';

class kFormatStyles{
  kFormatStyles._();

  static String formatCurrency(double amount){
    return NumberFormat.currency(locale: 'en_PK',symbol: 'PKR').format(amount);
  }
  static String formatContactNumber(String number){
    try{
      if(number.length==11){
        return '${number.substring(0,4)}-${number.substring(4,11)}';
      }else{
        return 'Enter 11 digit number';
      }
    }catch(e){
      return 'Formatting Error';
    }
  }
  /*static String internationalNumberFormat(String number){

  }*/
  static String dateFormat(DateTime? date, DateTime? time){
    date ??=DateTime.now();
    return DateFormat('dd-MM-yyyy').format(date);
  }
  static String timeFormat(DateTime? time) {
    time ??= DateTime.now();
    return DateFormat('hh:mm a').format(time);
  }
}
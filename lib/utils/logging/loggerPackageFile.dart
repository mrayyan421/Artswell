import 'package:logger/logger.dart';

class kLoggerLogic{//logger class to increase dev's code readability
  static final Logger _logger=Logger(//logger variable styling
    filter: null,
    printer: PrettyPrinter(methodCount: 2,
      errorMethodCount: 8,lineLength: 120,colors: true,printEmojis: true,dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart
   ),
    level: Level.debug,
  );
  static void error(String message){//error msg
    _logger.e(message);
  }
  static void warning(String message){//debug msg
    _logger.w(message);
  }
  static void info(String message){//info msg
    _logger.i(message);
  }
  static void debug(String message){//debug msg
    _logger.d(message);
  }
  static void fatalError(String message){//fatal error msg, application is unable to work further
    _logger.f(message);
  }
  }
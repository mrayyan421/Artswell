import 'dart:convert';
import 'package:http/http.dart' as http;

class kHttplogic{
  static const _nodeAPIKey=''; //API key node/express

  static Map<String,dynamic> _responseHandling(http.Response response){//function to handle http response
    if(response.statusCode==200){
      return jsonDecode(response.body);
    }else{
      throw Exception('Failed to fetch Data');
    }
  }
  static Future<Map<String,dynamic>> getRequest(String endPoint)async{//function to GET response
    final response=await http.get(Uri.parse('$_nodeAPIKey/$endPoint'),);
    return _responseHandling(response);
  }
  static Future<Map<String,dynamic>> postRequest(String endPoint, dynamic info)async{//function to deal with POST request
    final response=await http.post(Uri.parse('$_nodeAPIKey/$endPoint'),headers: {'Content-Type':'Application/json'},body: json.encode(info),);
    return _responseHandling(response);
  }
  static Future<Map<String,dynamic>> putRequest(String endPoint, dynamic info)async{//function to deal with PUT request
    final response=await http.put(Uri.parse('$_nodeAPIKey/$endPoint'),headers: {'Content-Type':'Application/json'},body: json.encode(info),);
    return _responseHandling(response);
  }
  static Future<Map<String,dynamic>> deleteRequest(String endPoint)async{//function to deal with delete request
    final response=await http.delete(Uri.parse('$_nodeAPIKey/$endPoint'),);
    return _responseHandling(response);
  }
}
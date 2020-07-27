import 'dart:convert';
import 'package:http/http.dart' as http;

class CallApi {
  postData(data, apiUrl) async {
    var fullUrl = apiUrl;
    //print(fullUrl);
    return await http.post(fullUrl, body: jsonEncode(data));
  }
}

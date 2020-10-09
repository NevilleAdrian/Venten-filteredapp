import 'dart:convert';

import 'package:filteredapp/Exceptions/api_failure_exception.dart';
import 'package:filteredapp/models/Filtercar.dart';
import 'package:http/http.dart' as http;


/// Helper class to make http request

class NetworkHelper {
  static const url = "https://ven10.co/assessment/filter.json";




  Future<List<FilterCar>> getCarFilter() async {
    var response = await http.get(url);
    print(response.body);
    var decoded = jsonDecode(response.body);
    if (response.statusCode.toString().startsWith('2')) {
      var filtercar = (decoded as List).map((datum) => FilterCar.fromJson(datum)).toList();
      print(filtercar);
      return filtercar;
    } else {
      print(
          'reason is ${response.reasonPhrase} message is ${decoded['message']}');
      throw ApiFailureException(decoded['message'] ?? response.reasonPhrase);
    }
  }


}

import 'dart:convert';
import 'dart:io';

import 'package:covidtracker/core/enum/state_enum.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'exceptions.dart';

class ApiClient {
  final http.Client client;
  final ApiService _apiService = ApiService();

  ApiClient({this.client});

  getNewsResponse(String value) async {
    String endpoint = _getNewsEndpoint(value);
    String url = _apiService.newsUrl +
        _apiService.query +
        "&" +
        _apiService.limit +
        "&" +
        endpoint +
        "&" +
        ApiService.apiKey;
    print('News URL: $url');
    try {
      http.Response response;
      if (client != null) {
        response = await client.get(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );
      } else {
        response = await http.get(url);
      }
      // var response = await http.get(url);

      var _jsonResponse = jsonDecode(response.body);
      print('News Response Body: $_jsonResponse');
      print('Status: ${_jsonResponse['status']}');

      if (_jsonResponse['status'] == "ok") {
        print('Status OK');
        return _jsonResponse;
      } else if (_jsonResponse['status'] == "error") {
        print('Status Error');
        throw FetchDataException(
            _jsonResponse['code'] + _jsonResponse['message']);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  getStatsResponse(StateLocation stateLocation,
      {String code = "", bool yesterday = false}) async {
    String endpoint = _getStatsEndpoint(
        location: stateLocation, code: code, yesterday: yesterday);
    String url = _apiService.statsUrl + endpoint;
    print('Stats URL: $url');
    try {
      http.Response response;
      if (client != null) {
        response = await client.get(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );
      } else {
        response = await http.get(url);
      }

      print('Stats Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        var _jsonResponse = json.decode(response.body);
        if (stateLocation == StateLocation.TOP_FIVE) {
          return _jsonResponse.sublist(0, 6);
        }
        return _jsonResponse;
      } else {
        throw FetchDataException("Failed to load stats");
      }
    } on SocketException {
      throw FetchDataException("No internet connection");
    }
  }

  _getStatsEndpoint(
      {@required String code,
      bool yesterday,
      @required StateLocation location}) {
    if (location == StateLocation.GLOBAL) return "all?yesterday=$yesterday";
    String endpoint = "countries";

    if (location == StateLocation.SPECIFIC) {
      endpoint += "/" + code + "?strict=false&";
    } else if (location == StateLocation.TOP_FIVE) {
      endpoint += "?sort=cases&";
    } else if (location == StateLocation.ALL) {
      endpoint += "?";
    }
    return endpoint + "allowNull=false&yesterday=$yesterday";
  }

  _getNewsEndpoint(String value) {
    if (value == "Last Week") {
      return "from=${_getDate(7)}&sortBy=popular";
    } else if (value == "Last 15") {
      return "from=${_getDate(15)}&sortBy=popular";
    } else if (value == "Last Month") {
      return "from=${_getDate(30)}&sortBy=popular";
    }
    return "from=${_getDate(10)}&sortBy=$value";
  }

  _getDate(int days) {
    var now = DateTime.now();
    now = now.subtract(Duration(days: days));
    var date = now.toString();
    date = date.split(" ")[0];
    return date;
  }
}

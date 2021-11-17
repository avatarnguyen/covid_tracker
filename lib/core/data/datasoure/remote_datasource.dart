import 'dart:convert';
import 'dart:io';

import 'package:covidtracker/network_requests/exceptions.dart';
import 'package:http/http.dart' as http;

abstract class RemoteDatasource {
  Future<dynamic> getData(String url);
}

class HTTPRemoteDatasource implements RemoteDatasource {
  const HTTPRemoteDatasource({this.client});

  final http.Client client;

  @override
  Future<dynamic> getData(String url) async {
    try {
      final _response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (_response.statusCode == 404) {
        throw FetchDataException("Failed to load data");
      } else {
        final Map<String, dynamic> _jsonResult = json.decode(_response.body);
        if (_jsonResult.containsKey('status')) {
          if (_jsonResult['status'] == 'ok') {
            return _jsonResult;
          } else if (_jsonResult['status'] == 'error') {
            throw FetchDataException(
                _jsonResult['code'] + _jsonResult['message']);
          }
        } else {
          return _jsonResult;
        }
      }
    } on SocketException catch (e) {
      print(e);
      throw FetchDataException('No Internet Connection');
    }
  }
}

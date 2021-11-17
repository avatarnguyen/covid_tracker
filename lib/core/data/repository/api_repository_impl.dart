import 'package:covidtracker/core/data/datasoure/remote_datasource.dart';
import 'package:covidtracker/core/domain/repository/api_repository.dart';
import 'package:covidtracker/core/enum/state_enum.dart';
import 'package:covidtracker/network_requests/api_service.dart';
import 'package:flutter/foundation.dart';

class ApiRepositoryImpl implements ApiRepository {
  ApiRepositoryImpl({this.apiService, this.remoteDatasource});

  final RemoteDatasource remoteDatasource;
  final ApiService apiService;

  @override
  Future<Map<String, dynamic>> getNewsResponse(String query) {
    final _endpoint = _getNewsEndpoint(query);
    final _url = """${apiService.newsUrl}&${apiService.limit}
        &$_endpoint&${ApiService.apiKey}""";
    return remoteDatasource.getData(_url);
  }

  @override
  Future<Map<String, dynamic>> getStatsResponse(
    StateLocation stateLocation, {
    String code = "",
    bool yesterday = false,
  }) {
    final _endpoint = _getStatsEndpoint(
        location: stateLocation, code: code, yesterday: yesterday);
    final _url = "${apiService.statsUrl}$_endpoint";
    return remoteDatasource.getData(_url);
  }

  String _getStatsEndpoint(
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

  String _getNewsEndpoint(String value) {
    if (value == "Last Week") {
      return "from=${_getDate(7)}&sortBy=popular";
    } else if (value == "Last 15") {
      return "from=${_getDate(15)}&sortBy=popular";
    } else if (value == "Last Month") {
      return "from=${_getDate(30)}&sortBy=popular";
    }
    return "from=${_getDate(10)}&sortBy=$value";
  }

  String _getDate(int days) {
    var now = DateTime.now();
    now = now.subtract(Duration(days: days));
    var date = now.toString();
    date = date.split(" ")[0];
    return date;
  }
}

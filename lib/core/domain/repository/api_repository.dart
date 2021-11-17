import 'package:covidtracker/core/enum/state_enum.dart';

abstract class ApiRepository {
  Future<Map<String, dynamic>> getNewsResponse(String query);
  Future<Map<String, dynamic>> getStatsResponse(
    StateLocation stateLocation, {
    String code = "",
    bool yesterday = false,
  });
}

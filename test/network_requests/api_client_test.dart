import 'dart:convert';

import 'package:covidtracker/network_requests/api_client.dart';
import 'package:covidtracker/network_requests/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient mockHttpClient;
  ApiClient apiClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiClient = ApiClient(client: mockHttpClient);
  });

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttpClientSuccess200(String fileName) {
    when(mockHttpClient.get(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer(
      (_) async {
        return http.Response(fixture(fileName), 200);
      },
    );
  }

  group(
    'HTTP Get Request for Stats',
    () {
      final tStatsJson = json.decode(fixture('stats.json'));
      test(
        'should throw an Exeption when HTTP Response is 404',
        () async {
          // arrange
          setUpMockHttpClientFailure404();
          // act
          final call = apiClient.getStatsResponse;
          // assert
          expect(() => call(StateLocation.ALL),
              throwsA(isA<FetchDataException>()));
        },
      );

      test(
        'should return json when get HTTP Response successfully',
        () async {
          // arrange
          setUpMockHttpClientSuccess200('stats.json');
          // act
          final result = await apiClient.getStatsResponse(StateLocation.GLOBAL);
          print(result);
          // assert
          expect(result, equals(tStatsJson));
        },
      );
    },
  );
  group(
    'HTTP Get Request for News',
    () {
      final tNewsJson = json.decode(fixture('news.json'));
      test(
        'should throw an Exeption when HTTP Response is 404',
        () async {
          // arrange
          when(mockHttpClient.get(
            any,
            headers: anyNamed('headers'),
          )).thenAnswer(
            (_) async {
              return http.Response(fixture('news_failed.json'), 404);
            },
          );
          // act
          final call = apiClient.getNewsResponse;
          // assert
          expect(() => call('publishedAt'), throwsA(isA<FetchDataException>()));
        },
      );

      test(
        'should return json when get HTTP Response successfully',
        () async {
          // arrange
          setUpMockHttpClientSuccess200('news.json');
          // act
          final result = await apiClient.getNewsResponse('publishedAt');
          // print(json.decode(result));
          // print(tNewsJson);

          // assert
          expect(result, equals(tNewsJson));
        },
      );
    },
  );
}

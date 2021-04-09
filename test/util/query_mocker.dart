import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mockito/mockito.dart';
import "package:http/http.dart";

class QueryMocker extends StatelessWidget {
  const QueryMocker({
    Key? key,
    required this.mockedResponse,
    required this.child,
  }) : super(key: key);

  final StreamedResponse mockedResponse;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      'https://test.com/graphql',
      httpClient: FakeHttpClient(
        mockedResponse: mockedResponse,
      ),
    );
    final client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}

class FakeHttpClient extends Fake implements Client {
  FakeHttpClient({
    required this.mockedResponse,
  });

  final StreamedResponse mockedResponse;

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return Future<StreamedResponse>.value(mockedResponse);
  }
}

// class MockLink extends Mock implements Link {
//   MockLink({
//     this.mockedResult = const {},
//   });
//   final Map<String, dynamic>? mockedResult;

//   @override
//   Stream<Response> request(
//     Request request, [
//     NextLink? forward,
//   ]) {
//     return Stream.fromIterable([Response(data: mockedResult)]);
//   }
// }

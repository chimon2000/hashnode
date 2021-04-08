import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ClientProvider extends StatelessWidget {
  ClientProvider({
    required this.client,
    required this.child,
  });

  final Widget child;
  final GraphQLClient client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier<GraphQLClient>(client),
      child: CacheProvider(child: child),
    );
  }
}

ValueNotifier<GraphQLClient> clientFor({
  required String uri,
  String? subscriptionUri,
  Client? httpClient,
}) {
  Link link = HttpLink(uri, httpClient: httpClient);
  if (subscriptionUri != null) {
    final WebSocketLink websocketLink = WebSocketLink(
      subscriptionUri,
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 30),
      ),
    );

    link = link.concat(websocketLink);
  }

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: cache,
      link: link,
    ),
  );
}

final GraphQLCache cache = GraphQLCache();

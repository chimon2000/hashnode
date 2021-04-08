import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLQueryBuilder<T> extends StatelessWidget {
  GraphQLQueryBuilder({
    required this.options,
    required this.serializer,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.builder,
  });

  final BuilderFn<T> builder;
  final ErrorBuilderFn errorBuilder;
  final LoadingBuilderFn loadingBuilder;
  final QueryOptions options;
  final SerializerFn<T> serializer;

  @override
  Widget build(BuildContext context) {
    return Query(
      options: options,
      builder: (result, {refetch, fetchMore}) {
        if (result.hasException) {
          return errorBuilder(context, result);
        }

        if (result.isLoading && result.data == null) {
          return loadingBuilder(context, result);
        }

        final T data = serializer(result.data);

        return builder(context, data, refetch: refetch, fetchMore: fetchMore);
      },
    );
  }
}

typedef BuilderFn<T> = Widget Function(
  BuildContext context,
  T story, {
  Refetch? refetch,
  Function(FetchMoreOptions)? fetchMore,
});
typedef ErrorBuilderFn = Widget Function(BuildContext, QueryResult);
typedef LoadingBuilderFn = Widget Function(BuildContext, QueryResult);
typedef SerializerFn<T> = T Function(Map<String, dynamic>? json);

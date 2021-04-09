import 'dart:convert';

import "package:http/http.dart";

StreamedResponse buildGoodResponse(Map<String, dynamic> mockedResult,
    [int mockedStatus = 200]) {
  return StreamedResponse(
    Stream.value(utf8.encode(jsonEncode(mockedResult))),
    mockedStatus,
  );
}

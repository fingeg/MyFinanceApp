import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const host = "http://192.168.178.71:8000";

enum HttpMethod { POST, GET, PUT, DELETE }

const _methods = ['POST', 'GET', 'PUT', 'DELETE'];

extension HttpMethodExtension on HttpMethod {
  String getName() => _methods[index];
}

enum StatusCode {
  success,
  unauthorized,
  forbidden,
  offline,
  failed,
  wrongFormat,
  conflict,
}

extension StatusCodeExtension on StatusCode {
  StatusCode reduce(StatusCode statusCode) {
    if (this == statusCode) {
      return this;
    }
    if ([this, statusCode].contains(StatusCode.unauthorized)) {
      return StatusCode.unauthorized;
    }
    if ([this, statusCode].contains(StatusCode.forbidden)) {
      return StatusCode.forbidden;
    }
    if ([this, statusCode].contains(StatusCode.offline)) {
      return StatusCode.offline;
    }
    if ([this, statusCode].contains(StatusCode.wrongFormat)) {
      return StatusCode.wrongFormat;
    }
    return StatusCode.failed;
  }

  StatusCode reduceAll(List<StatusCode> statusCodes) =>
      statusCodes.reduce((code1, code2) => code1.reduce(code2));
}

class Authentication {
  final String username;
  final String sessionProof;
  final int sessionID;

  Authentication(this.username, this.sessionProof, this.sessionID);
}

class ApiResponse<T> {
  final T data;
  final StatusCode statusCode;
  final bool status;
  final String errorMsg;

  ApiResponse({this.data, this.statusCode, this.status, this.errorMsg});
}

ApiResponse<T> _parseJson<T>(
    String path, String rawJson, T Function(Map<String, dynamic>) jsonParser) {
  try {
    final data = jsonParser(json.decode(rawJson));
    return ApiResponse<T>(data: data, statusCode: StatusCode.success);
  } catch (e, stacktrace) {
    print('Failed to parse $path: $e\n$stacktrace');
    return ApiResponse<T>(statusCode: StatusCode.wrongFormat);
  }
}

Future<ApiResponse<T>> request<T>(String path, HttpMethod httpMethod,
    {Authentication authentication,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) jsonParser}) async {
  final dio = Dio()
    ..options = BaseOptions(
      headers: authentication != null
          ? {
              'authorization':
                  'Basic ${base64.encode(utf8.encode('${authentication.username}:${authentication.sessionProof}'))}',
              'session_id': authentication.sessionID,
            }
          : null,
      responseType: ResponseType.plain,
      connectTimeout: 3000,
      receiveTimeout: 3000,
    );

  if (!path.startsWith('/')) {
    path = '/$path';
  }

  try {
    Response res = await dio.request(
      '$host$path',
      data: data,
      options: Options(method: httpMethod.getName()),
    );
    if (res.statusCode != 200) {
      throw DioError(response: res, type: DioErrorType.RESPONSE);
    }

    return _parseJson(path, res.toString(), jsonParser);
  } on DioError catch (e) {
    switch (e.type) {
      case DioErrorType.RESPONSE:
        final data = e.response.data.toString();
        Map<String, dynamic> parsed;
        try {
          parsed = json.decode(data);
        } catch (_) {
          parsed = {};
        }
        StatusCode statusCode;
        switch (e.response.statusCode) {
          case 401:
            statusCode = StatusCode.unauthorized;
            break;
          case 403:
            statusCode = StatusCode.forbidden;
            break;
          case 400:
            print(
                'Request body is incorrect (path: $path, method: ${httpMethod.getName()})!');
            statusCode = StatusCode.failed;
            break;
          case 409:
            statusCode = StatusCode.conflict;
            break;
          default:
            statusCode = StatusCode.failed;
            break;
        }
        return ApiResponse(
            statusCode: statusCode,
            status: (parsed['status'] ?? '') == 'true',
            errorMsg: (parsed['error'] ?? ''));
      case DioErrorType.DEFAULT:
        if (e.error is SocketException) {
          print('Failed to load $path: offline');
          return ApiResponse(statusCode: StatusCode.offline);
        }
        print('Failed to load $path: ${e.type}:\n${e.error}');
        return ApiResponse(statusCode: StatusCode.failed);
      default:
        print('Failed to load $path: ${e.type}:\n${e.error}');
        return ApiResponse(statusCode: StatusCode.failed);
    }
  }
}

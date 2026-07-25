import 'dart:async' as async;
import 'dart:io';

import 'package:dio/dio.dart';

/// Base type for user-facing app errors.
///
/// Controllers should always surface [message] (via [AppException.messageOf]),
/// never a raw `e.toString()` from platform/Dio failures.
abstract class AppException implements Exception {
  const AppException(this.message);

  /// Short, human-readable copy safe to show in the UI.
  final String message;

  @override
  String toString() => message;

  /// Resolves a caught object to a user-facing string.
  static String messageOf(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AppException) return error.message;
    return fallback;
  }
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = "Couldn't reach the server. Please try again.",
  ]);
}

/// Request timed out (connect / send / receive).
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Request timed out. Check your connection.',
  ]);
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'The server returned an error. Please try again.',
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Something went wrong. Please try again.',
  ]);
}

/// Maps Dio / socket / timeout failures into [AppException] subtypes.
class ExceptionMapper {
  ExceptionMapper._();

  static AppException from(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return const TimeoutException();
        case DioExceptionType.connectionError:
          return const NetworkException();
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          return ServerException(
            code == null
                ? 'The server returned an error. Please try again.'
                : 'Server error ($code). Please try again.',
          );
        case DioExceptionType.cancel:
          return const UnknownException('Request was cancelled.');
        case DioExceptionType.badCertificate:
          return const NetworkException(
            "Couldn't establish a secure connection. Please try again.",
          );
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkException();
          }
          if (error.error is async.TimeoutException) {
            return const TimeoutException();
          }
          return const UnknownException();
      }
    }

    if (error is SocketException) {
      return const NetworkException();
    }

    if (error is async.TimeoutException) {
      return const TimeoutException();
    }

    return const UnknownException();
  }
}

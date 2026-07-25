import 'dart:async' as async;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/core/errors/app_exception.dart';

void main() {
  group('AppException.messageOf', () {
    test('returns AppException.message when available', () {
      expect(
        AppException.messageOf(const NetworkException()),
        "Couldn't reach the server. Please try again.",
      );
    });

    test('returns fallback for unknown errors', () {
      expect(
        AppException.messageOf(Exception('boom'), fallback: 'Safe message'),
        'Safe message',
      );
    });
  });

  group('ExceptionMapper', () {
    test('passes through existing AppException', () {
      const original = ServerException('Already mapped');
      expect(ExceptionMapper.from(original), same(original));
    });

    test('maps connection timeouts to TimeoutException', () {
      final mapped = ExceptionMapper.from(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(mapped, isA<TimeoutException>());
      expect(mapped.message, contains('timed out'));
    });

    test('maps connection errors to NetworkException', () {
      final mapped = ExceptionMapper.from(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(mapped, isA<NetworkException>());
    });

    test('maps bad responses to ServerException with status code', () {
      final mapped = ExceptionMapper.from(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/'),
            statusCode: 503,
          ),
        ),
      );
      expect(mapped, isA<ServerException>());
      expect(mapped.message, contains('503'));
    });

    test('maps SocketException to NetworkException', () {
      final mapped = ExceptionMapper.from(
        const SocketException('Failed host lookup'),
      );
      expect(mapped, isA<NetworkException>());
    });

    test('maps dart:async TimeoutException to TimeoutException', () {
      final mapped = ExceptionMapper.from(
        async.TimeoutException('late'),
      );
      expect(mapped, isA<TimeoutException>());
    });

    test('maps unknown objects to UnknownException', () {
      final mapped = ExceptionMapper.from('not an exception object');
      expect(mapped, isA<UnknownException>());
    });
  });
}

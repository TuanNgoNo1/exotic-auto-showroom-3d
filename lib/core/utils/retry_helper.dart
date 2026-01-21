import 'dart:async';
import 'dart:math';

/// Helper class để retry các operations với exponential backoff
class RetryHelper {
  /// Retry một async operation với exponential backoff
  /// 
  /// [operation]: Function cần retry
  /// [maxAttempts]: Số lần thử tối đa (default: 3)
  /// [initialDelay]: Delay ban đầu (default: 1 giây)
  /// [maxDelay]: Delay tối đa (default: 30 giây)
  /// [shouldRetry]: Function để quyết định có retry không dựa trên error
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      attempts++;
      try {
        return await operation();
      } on Exception catch (e) {
        // Kiểm tra có nên retry không
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // Đã hết số lần thử
        if (attempts >= maxAttempts) {
          rethrow;
        }

        // Chờ trước khi retry
        await Future.delayed(delay);

        // Tăng delay theo exponential backoff với jitter
        final jitter = Random().nextDouble() * 0.3; // 0-30% jitter
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * (1.5 + jitter)).round(),
            maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }

  /// Kiểm tra error có phải là network error không
  static bool isNetworkError(Exception e) {
    final errorString = e.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable');
  }

  /// Retry chỉ với network errors
  static Future<T> retryOnNetworkError<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
  }) {
    return retry(
      operation: operation,
      maxAttempts: maxAttempts,
      shouldRetry: isNetworkError,
    );
  }
}

/// Extension để dễ sử dụng retry
extension FutureRetryExtension<T> on Future<T> Function() {
  /// Retry future với default settings
  Future<T> withRetry({int maxAttempts = 3}) {
    return RetryHelper.retry(
      operation: this,
      maxAttempts: maxAttempts,
    );
  }

  /// Retry future chỉ khi network error
  Future<T> withNetworkRetry({int maxAttempts = 3}) {
    return RetryHelper.retryOnNetworkError(
      operation: this,
      maxAttempts: maxAttempts,
    );
  }
}

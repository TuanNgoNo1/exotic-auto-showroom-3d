/// Base exception class cho app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException([String message = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.'])
      : super(message, code: 'NETWORK_ERROR');
}

/// Authentication exceptions
class AuthException extends AppException {
  AuthException(super.message, {super.code});

  factory AuthException.invalidCredentials() =>
      AuthException('Email hoặc mật khẩu không đúng', code: 'INVALID_CREDENTIALS');

  factory AuthException.emailNotConfirmed() =>
      AuthException('Vui lòng xác nhận email trước khi đăng nhập', code: 'EMAIL_NOT_CONFIRMED');

  factory AuthException.userNotFound() =>
      AuthException('Tài khoản không tồn tại', code: 'USER_NOT_FOUND');

  factory AuthException.emailAlreadyExists() =>
      AuthException('Email này đã được đăng ký', code: 'EMAIL_EXISTS');

  factory AuthException.weakPassword() =>
      AuthException('Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn', code: 'WEAK_PASSWORD');

  factory AuthException.notAuthenticated() =>
      AuthException('Vui lòng đăng nhập để tiếp tục', code: 'NOT_AUTHENTICATED');
}

/// Database/Supabase exceptions
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.code, super.originalError});

  factory DatabaseException.notFound([String? item]) =>
      DatabaseException('${item ?? 'Dữ liệu'} không tồn tại', code: 'NOT_FOUND');

  factory DatabaseException.queryFailed([String? details]) =>
      DatabaseException('Lỗi truy vấn dữ liệu${details != null ? ': $details' : ''}',
          code: 'QUERY_FAILED');
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException(super.message, {super.code, super.originalError});

  factory StorageException.uploadFailed() =>
      StorageException('Tải file lên thất bại', code: 'UPLOAD_FAILED');

  factory StorageException.downloadFailed() =>
      StorageException('Tải file xuống thất bại', code: 'DOWNLOAD_FAILED');

  factory StorageException.fileNotFound() =>
      StorageException('File không tồn tại', code: 'FILE_NOT_FOUND');
}

/// Garage exceptions
class GarageException extends AppException {
  GarageException(super.message, {super.code});

  factory GarageException.alreadyInGarage() =>
      GarageException('Xe đã có trong Garage', code: 'ALREADY_IN_GARAGE');

  factory GarageException.notInGarage() =>
      GarageException('Xe không có trong Garage', code: 'NOT_IN_GARAGE');
}

/// Helper để parse error từ Supabase
class ExceptionParser {
  static AppException parse(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('network') ||
        errorString.contains('timeout')) {
      return NetworkException();
    }

    // Auth errors
    if (errorString.contains('invalid login credentials')) {
      return AuthException.invalidCredentials();
    }
    if (errorString.contains('email not confirmed')) {
      return AuthException.emailNotConfirmed();
    }
    if (errorString.contains('user not found')) {
      return AuthException.userNotFound();
    }
    if (errorString.contains('already registered')) {
      return AuthException.emailAlreadyExists();
    }
    if (errorString.contains('weak password')) {
      return AuthException.weakPassword();
    }

    // Database errors
    if (errorString.contains('not found') || errorString.contains('no rows')) {
      return DatabaseException.notFound();
    }

    // Default
    return DatabaseException(
      'Đã xảy ra lỗi. Vui lòng thử lại.',
      originalError: error,
    );
  }
}

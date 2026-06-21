sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Database operation failed.']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Storage operation failed.']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Record not found.']);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}

import 'dart:async';

class Debouncer<T> {
  final Duration delay;
  Timer? _timer;
  Completer<T>? _completer;

  Debouncer({required this.delay});

  Future<T> run(FutureOr<T> Function() action) {
    _timer?.cancel();

    if (_completer == null || _completer?.isCompleted == true) {
      _completer = Completer<T>();
    }

    _timer = Timer(delay, () async {
      try {
        final result = await action();
        _completer?.complete(result);
      } catch (e) {
        _completer?.completeError(e);
      }
    });

    return _completer!.future;
  }

  void cancel() {
    _timer?.cancel();
    _completer?.completeError('Debounce cancelled');
  }
}

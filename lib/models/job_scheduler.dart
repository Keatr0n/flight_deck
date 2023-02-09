class JobScheduler {
  final List<Future<void> Function()> _jobs = [];

  bool _isRunning = false;

  void addJob(Future<void> Function() job) {
    _jobs.add(job);

    _runJobs();
  }

  Future<void> _runJobs() async {
    if (_isRunning) return;
    _isRunning = true;

    while (_jobs.isNotEmpty) {
      final job = _jobs.removeAt(0);
      await job();
    }

    _isRunning = false;
  }
}

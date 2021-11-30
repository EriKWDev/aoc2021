import "dart:io";

Future<void> compileSolution(String path) async {
  var compileProcess = await Process.start("dart", ["compile", "exe", path]);

  await compileProcess.exitCode;
}

class Result extends Object {
  final Duration duration;
  final int times;
  final String path;

  String get name => path.split(Platform.pathSeparator).last.split(".").first;

  const Result({required this.duration, required this.times, required this.path});

  static const prettySeparator = ".";

  @override
  String toString() {
    var time = duration.inMilliseconds.toString();
    return "${name.padRight(20, prettySeparator)}${prettySeparator}${time.padLeft(8, prettySeparator)} ms (ran $times times)";
  }
}

Future<Result> measurePerformance(String path) async {
  var done = false;

  Future.delayed(const Duration(seconds: 15), () {
    done = true;
  });

  int i = 0;

  List<Duration> times = [];

  while (!done) {
    var process = await Process.start(path, ["--performance"]);

    final stopwatch = Stopwatch()..start();
    await process.exitCode;
    stopwatch.stop();

    times.add(stopwatch.elapsed);
    i++;

    if (i >= 150) {
      done = true;
    }
  }

  var averageDuration = Duration(microseconds: times.reduce((value, element) => value + element).inMicroseconds ~/ i);
  await File(path).delete();
  return Result(duration: averageDuration, times: i, path: path);
}

measurePerformanceForYear(int year) async {
  var aocPattern = RegExp("^((${year})_(\\d+).dart)\$");

  var solutionsDirectory = Directory("${Directory.current.path}${Platform.pathSeparator}solutions");
  List<String> paths = [];

  for (var file in solutionsDirectory.listSync(recursive: true)) {
    var filename = file.path.split(Platform.pathSeparator).last;

    if (aocPattern.hasMatch(filename)) {
      paths.add(file.path);
    }
  }

  if (paths.isEmpty) {
    return;
  }

  await Future.wait(paths.map((path) => compileSolution(path)));
  stdout.writeln();

  List<Future> concurrent = [];
  List<Result> results = [];

  for (var path in paths) {
    stdout.write("Running...\r");

    concurrent.add(measurePerformance(path.split(".")[0] + ".exe").then((value) {
      stdout.write("${value.name}: ${value.duration.inMilliseconds} ms\r");
      results.add(value);
    }));

    if (concurrent.length >= maxConcurrent) {
      await Future.wait(concurrent);
      concurrent.clear();
    }
  }

  await Future.wait(concurrent);
  results.sort((a, b) => a.duration.compareTo(b.duration));

  stdout.writeln("Performance Results for $year");
  for (var result in results) {
    print(result);
  }
}

const maxConcurrent = 12;
const years = [2021, 2020];

void main() async {
  for (var year in years) {
    await measurePerformanceForYear(year);
  }
}

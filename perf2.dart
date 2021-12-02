import 'dart:async';

import "./lib/utils.dart";

import "./solutions/2021/2021_01.dart" as solution202101;
import "./solutions/2021/2021_02.dart" as solution202102;

import "./solutions/2020/2020_19.dart" as solution202019;
import "./solutions/2020/2020_20.dart" as solution202020;
import "./solutions/2020/2020_23.dart" as solution202023;
import "./solutions/2020/2020_24.dart" as solution202024;
import "./solutions/2020/2020_25.dart" as solution202025;

var allParts = {
  // 2021
  solution202101.today: [solution202101.part1, solution202101.part2],
  solution202102.today: [solution202102.part1, solution202102.part2],
  // 2020
  solution202019.today: [solution202019.part1, solution202019.part2],
  solution202020.today: [solution202020.part1, solution202020.part2],
  solution202023.today: [solution202023.part1, solution202023.part2],
  solution202024.today: [solution202024.part1, solution202024.part2],
  solution202025.today: [solution202025.part1, solution202025.part2],
};

class Result {
  final Duration totalTime;
  final int timesRun;
  final String name;

  Duration get averageTime => Duration(microseconds: totalTime.inMicroseconds ~/ timesRun);

  String get timeString {
    if (averageTime.inMilliseconds > 0) {
      return "${averageTime.inMilliseconds} ms";
    }

    return "${averageTime.inMicroseconds} μs";
  }

  @override
  String toString() {
    return "$name ........ $averageTime";
  }

  const Result({required this.totalTime, required this.timesRun, required this.name});
}

class CombinedResult extends Result {
  Result result1;
  Result result2;

  @override
  Duration get averageTime => result1.averageTime + result2.averageTime;

  CombinedResult(this.result1, this.result2, String name)
      : super(
            name: name,
            totalTime: result1.totalTime + result2.totalTime,
            timesRun: result1.timesRun + result2.timesRun);

  static Future<CombinedResult> fromFutures(Future<Result> r1, Future<Result> r2, String name) async {
    return CombinedResult(await r1, await r2, name);
  }

  @override
  String toString() {
    var result = "$name..............$averageTime";

    result += "\n  $result1";
    result += "\n  $result2";

    return result;
  }
}

typedef Part = dynamic Function(String input);

Future<Result> measurePart(Part part, String input, String name) async {
  var done = false;

  Duration totalTime = Duration.zero;

  int n = 0;
  print("Measuring $name...");

  while (!done) {
    var stopWatch = Stopwatch()..start();
    var answer = part(input);
    stopWatch.stop();
    // print("Answer: $answer ($done)");

    await Future.delayed(Duration.zero);

    totalTime += stopWatch.elapsed;
    n++;

    if (totalTime > Duration(seconds: 5) || n >= 100) {
      done = true;
    }
  }

  print("Done measuring $name");

  return Result(timesRun: n, totalTime: totalTime, name: name);
}

void main(List<String> args) async {
  List<Future<CombinedResult>> results = [];
  List<Future<Result>> partResults = [];
  List<Future<Result>> concurrent = [];

  for (var entry in allParts.entries) {
    var parts = entry.value;
    var date = entry.key;
    var name = "${date.year}_${date.day.toString().padLeft(2, '0')}";

    var input = await fetchInput(date);
    var r1 = measurePart(parts[0], input, "$name part 1");
    var r2 = measurePart(parts[1], input, "$name part 2");

    partResults.addAll([r1, r2]);

    var combinedFuture = CombinedResult.fromFutures(r1, r2, name);
    results.add(combinedFuture);
    concurrent.addAll([r1, r2]);

    if (concurrent.length > 2) {
      await Future.wait(concurrent);
      concurrent.clear();
    }
  }

  List<CombinedResult> awaitedResults = [];
  for (var result in results) {
    awaitedResults.add(await result);
  }

  awaitedResults.sort((a, b) => a.averageTime.compareTo(b.averageTime));

  print("");
  for (var result in awaitedResults) {
    print(result);
    print("");
  }

  Map<String, List<Result>> partResultsByYear = {};

  List<Result> awaitedPartResults = [];
  for (var result in partResults) {
    var r = await result;
    awaitedPartResults.add(r);

    var key = r.name.split("_")[0];

    if (!partResultsByYear.containsKey(key)) {
      partResultsByYear[key] = [];
    }

    partResultsByYear[key]!.add(r);
  }

  awaitedPartResults.sort((a, b) => a.averageTime.compareTo(b.averageTime));

  for (var result in awaitedPartResults) {
    var avgMilliseconds = result.totalTime.inMicroseconds.toDouble() / result.timesRun.toDouble() / 1000.0;
    var ms = avgMilliseconds.toStringAsFixed(4);

    print("${result.name}.................$ms ms");
  }
  print("");

  for (var entry in partResultsByYear.entries) {
    var results = entry.value;
    results.sort((a, b) => a.averageTime.compareTo(b.averageTime));
    print("Performance Results for ${entry.key}");

    for (var result in results) {
      var avgMilliseconds = result.totalTime.inMicroseconds.toDouble() / result.timesRun.toDouble() / 1000.0;
      var ms = avgMilliseconds.toStringAsFixed(4);

      print("${result.name}.................$ms ms (ran ${result.timesRun} times)");
    }
    print("");
  }
}

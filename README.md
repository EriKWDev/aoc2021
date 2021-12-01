# Advent of Code 2021
All solutions can be found in the `solutions` folder.
## Usage
Don't forget to have `AOC_SESSION=<your_session_token>` loaded into your environment in order to use dynamic loading of input files as well as automatic submission. Alternatively, you can create a `env.json` with the content `{"sessions": ["<your_session_token>"]}`


## Performance
`perf.dart` compiles all solutions to executables, runs them as many times as it  can in 20 seconds (or until it has been run 200 times), and takes the average execution time. Here are the results, sorted by year and speed:

```
Performance Results for 2021
2021_01.....................6 ms (ran 200 times)

Performance Results for 2020
2020_20.....................6 ms (ran 200 times)
2020_19....................39 ms (ran 200 times)
2020_25....................73 ms (ran 200 times)
2020_23..................2148 ms (ran 12 times)
2020_24..................2348 ms (ran 11 times)
```
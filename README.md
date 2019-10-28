# Timmy

**Time execution of command and its stages marked by console output.**

This tool allows to measure how much an arbitrary command line tool spends on each stage of its execution as long as it prints lines to standard output to indicate when these stages start and end.

## Installation

Install the gem globally:

    gem install timmy

## Usage

Pipe the output from any command to it, e.g. from `docker build`:

    docker build . | timmy

As the most basic means for timing, each line of command output will be prefixed by total time elapsed since `timmy` has started.

In addition, `timmy` is capable of capturing and timing specific stages of command execution by matching the output against its meter definitions. For example, there's a built-in support provided for `docker build` which means that:

- meter is started every time Docker outputs something like `Step 16/22 : RUN bundle`
- meter is stopped when Docker outputs something like ` ---> 8912f93fa8a5` and `timmy` prints the duration of a Docker build step that has just finished

In the end, `timmy` will also write the entire output to a log file in `/tmp` in order to make it easier to run a series of benchmarks and refer back to their results.

## Configuration

You can add your own meters by creating `~/.timmy.rb` like below:

```ruby
Timmy::Meters.add(:docker_build_step,
  start_regex: /Step \d+\/\d+ : (?<title>.*)$/,
  end_regex: / ---> [0-9a-f]{12}$/)
```

Note that `end_regex` is optional - if absent, previous meter instance will be stopped every time a new is started.

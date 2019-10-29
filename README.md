# Timmy

**Time execution of commands and their stages based on console output.**

A simple command line tool that allows to measure how much time an arbitrary command spends on each stage of execution by annotating the command output with timestamps as well as running command-specific targeted timers.

## Installation

Install the gem as a global executable:

    gem install timmy

## Usage

### Basic example

Pipe the output from any command, e.g. from `docker build`:

    docker build . | timmy

Each line of the command output will be prefixed by total time elapsed since it has started.

Entire output from command, including time annotations, will be written to a log file in `/tmp` for future reference (i.e. during benchmarking).

### Replay log

You can reprint log from previous session via:

    timmy -r /tmp/timmy-1572347993+235.log

Currently passed options and targeted timers will be applied to the output just like the command would've been executed with them in the first place.

### Profile

You can present a list of slowest targeted timers after the command ends via:

    docker build . | timmy -p

Or by replaying previous session:

    timmy -p -r /tmp/timmy-1572347993+235.log

### Targeted timers

You can run command-specific timers in order to measure specific stages of command execution by matching the output against regular expressions that detect the moment when stage begins and (optionally) when it ends.

For example, there's a built-in support provided for `docker build` which means that:

- timer starts when Docker outputs `Step 16/22 : RUN bundle`
- timer stops and stage time gets logged when Docker outputs ` ---> 8912f93fa8a5`

You can add your own targeted timers via the configuration file.

## Configuration

You can add your own timers or adjust logging behavior by creating `~/.timmy.rb`.

Here's a complete example of such file:

```ruby
# save logs to different directory (default: "/tmp")
Timmy::Logger.set_output_directory("~/.timmy_log")

# change the precision used when printing time in logs (default: 0)
Timmy::Logger.set_precision(1)

# define custom targeted timer (based on default :docker_build timer)
Timmy::TargetedTimerDefinition.add(:docker_build,
  start_regex: /Step \d+\/\d+ : (?<label>.*)$/,
  stop_regex: / ---> [0-9a-f]{12}$/)

# define custom targeted timer (no label, no stop_regex)
Timmy::TargetedTimerDefinition.add(:misc, start_regex: / --- /)
```

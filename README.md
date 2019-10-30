# Timmy

**Time execution of commands and their stages based on console output.**

Measure how much time an arbitrary command spends on each stage of execution by annotating the command output with timestamps as well as running command-specific targeted timers. Profile slowest stages. Save and replay each session (for benchmarking purposes).

Tool is named after an unfortunate character from the *Giants: Citizen Kabuto* game who happened to be in the wrong place at the wrong time (learn more: [EN](https://www.youtube.com/watch?v=4Sh_VuxYqBY) / [PL](https://www.youtube.com/watch?v=hoVxsSvEpOo)).

## Installation

Install the gem as a global executable:

    gem install timmy

## Usage

### Basic example

Pipe the output from any command, e.g. from `docker build`:

```sh
docker build . | timmy
```

Each line of the command output will be prefixed by total time elapsed since it has started. You can set the precision used when printing that time:

```sh
docker build . | timmy --precision 1
```

Entire output from command, including time annotations, will be written to a log file in `/tmp` so that the session can be replayed.

### Replay session

You can replay previous session via:

```sh
cat /tmp/timmy-1572347993+235.log | timmy
```

Currently passed options and targeted timers will be applied to the output just like the command would've been executed with them in the first place.

By default the session will be replayed as fast as possible, but it's possible to simulate the actual time flow via:

```sh
cat /tmp/timmy-1572347993+235.log | timmy --replay-speed 1    # original speed
cat /tmp/timmy-1572347993+235.log | timmy --replay-speed 0.5  # 2x slower
cat /tmp/timmy-1572347993+235.log | timmy --replay-speed 10   # 10x faster
```

### Targeted timers

You can run command-specific timers in order to measure specific stages of command execution by matching the output against regular expressions that detect the moment when stage begins and (optionally) when it ends.

For example, there's a built-in support provided for `docker build` which means that:

- timer starts when Docker outputs `Step 16/22 : RUN bundle`
- timer stops and stage time gets logged when Docker outputs ` ---> 8912f93fa8a5`

You can add your own targeted timers via the configuration file.

### Profile

You can present a list of slowest targeted timers after the command ends via:

```sh
docker build . | timmy --profile
cat /tmp/timmy-1572347993+235.log | timmy --profile
```

### Options

Learn more about the tool usage and command line options available:

```sh
timmy --help
```

Note that command line options will ovverride relevant calls in a configuration file.

## Configuration

You can add your own timers or adjust logging behavior by creating `~/.timmy.rb`.

Here's a complete example of such file:

```ruby
Timmy.configure do |config|
  # Profile slowest targeted timers (default: false)
  config.set_profile(true)

  # Save logs to different directory (default: "/tmp")
  config.set_logger_output_dir("~")

  # Set precision used when printing time (default: 0)
  config.set_precision(1)

  # Replay with given speed (default: instant)
  config.set_replay_speed(1.0)

  # Redefine the default :docker_build timer (original regexes below)
  config.add_timer(:docker_build,
    start_regex: /Step \d+\/\d+ : (?<label>.*)$/,
    stop_regex: / ---> [0-9a-f]{12}$/)

  # Define custom timer with no label and no stop_regex
  config.add_timer(:simple, start_regex: /^--- /)

  # Define custom timer that groups timers by service names from `docker-compose logs`
  config.add_timer(:grouped,
    start_regex: /((?<group>[\w\-]+) +\| )?Begin (?<label>.*)$/,
    stop_regex: /((?<group>[\w\-]+) +\| )?End$/)

  # Delete the default :docker_build timer
  config.delete_timer(:docker_build)
end
```

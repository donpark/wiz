Makes command-line tools easier to use through implicit option files.

Advantages over adding `alias` to `.bashrc`:

1. folder specific options
2. easier format for reading, editing, and sharing
3. comments on options

Only disadvantages I can see compared to adding `alias` is the need to
install stuff. But then I'm biased. :-)

## Status

I'm just getting started so do not consider anything bolted down until
version is at least `0.2.0`.

## Installation

        npm install -g wiz

## Usage

### Create a custom version of `ack` command named `zack`

        wiz curry ack    # creates ~/.wiz/bin/zack [1]
        wiz link zack    # creates /usr/local/bin/zack -> ~/.wiz/bin/zack [2]

1. Because `wiz curry` command didn't provide a name for the custom command,
   default name with `z` prefix is used.

2. `wiz link` step is unnecessary if you have `~/.wiz/bin` in your `PATH`.

### Create an option file for `zack`

Option file for `zack` must be named `zack.opts` and may be located in any
directories between current working directory and `HOME` directory. Option
file may also be stored in each directory's `.wiz` directory.

Directories searched when current working directory is `/Users/don/github/wiz`:

        /Users/don/github/wiz
        /Users/don/github/wiz/.wiz
        /Users/don/github
        /Users/don/github/.wiz
        /Users/don
        /Users/don/.wiz

Example `zack.opts` file

        -i
        --ignore-dir node_modules

        # this requires ack 2.0
        --nojs

Option lines starting with `#` in option files are ignored.

### Using `zack`

        zack hello

This command line is equivalent to:

        ack -i --ignore-dir node_modules --nojs hello

### Create another version of `ack` for just searching css files

Full syntax of `wiz curry` command is

        wiz curry <target-command> [<curry-cmd>]

Default `<curry-cmd>` is target command name prefixed with `z`.

Example creating a curry command with non-default name

        wiz curry ack ackcss

`ackcss` will use option files named `ackcss.opts` if exists

### Remove `zack` from `/usr/local/bin`

        wiz unlink zack

## Platform support

Developed and tested on OS X.

Should not have issues with Linux except for `wiz link` command.

Windows is currently not supported. Hope to address this at some point.
Any help in this regard is welcome.

## Caveats

`wiz` has issues with **interactive command-line tools** and tools
that behaves differently based on whether `stdin` is TTY or not.

In case of `ag` which falls in the second category, add `--parallel` option.

fs = require('fs')
path = require('path')
exists = fs.exists or path.exists

async = require('async')
shell = require('shelljs') # only `which` is used

class WizCLI
  constructor: (@config) ->

  get: (name) -> @config[name]
  set: (name, value) -> @config[name] = value

  run: (cmd, args) ->
    if not cmd
      @error "no command to run"
    else
      handler = require("./wiz-#{cmd}")
      if not handler
        @error "#{cmd}: unknown command"
      else
        handler args, @, {}

  exit: (code = 0) -> process.exit(code)
  
  echo: (text) -> console.log "#{@get('name')}: #{text}"
  
  help: -> console.log """
    Usage: wiz <command> <args>

    Command form:

      wiz curry <shell_cmd> [<curry_cmd>]
    
    Examples:

      wiz curry ack zack  # create curried command 'zack' that calls 'ack'
      wiz curry ack       # equivalent to above
      wiz curry ack ackjs # create curried 'ack' for searching only .js files
    
    Description: Create new shell command named <curry_cmd> that
    executes <shell_cmd> with additional options specified in file
    named `<curry_cmd>.opts` if it exists in any directories between
    current working directory and user's home directory.

    Each directory's ".wiz" directory will also be searched.


    Command form:

      wiz link <curry_cmd>

    Examples:

      wiz link zack
      wiz link zcoffee

    Description: Creates a symbolic link with same name at /usr/local/bin.


    Command form:

      wiz unlink <curry_cmd>

    Examples:

      wiz unlink zack
      wiz unlink zcoffee

    Description: Removes symbolic link with same name at /usr/local/bin.


    Command form:

      wiz run <shell_cmd> <curry_cmd> <shell_cmd_args>
    
    Examples:

      wiz run ack zack    # execute ack using options in 'zack.opts'
      wiz run ack ackjs   # execute ack using options in 'ackjs.opts'

    Description: This command form is intended for use to implement
    curry shell scripts and may change in future versions.

    Command form:

      wiz run <shell_cmd> <curry_cmd> <shell_cmd_args>
    
    Examples:

      wiz run ack zack    # execute ack using options in 'zack.opts'
      wiz run ack ackjs   # execute ack using options in 'ackjs.opts'

    Description: This command form is intended for use to implement
    curry shell scripts and may change in future versions.
    """

  error: (message, showhelp = true) ->
    @echo message
    @help() if showhelp
    @exit(1)

  check_shell_command: (wiz_cmd, cmd) ->
    if not cmd
      @error "no shell command to #{wiz_cmd}"
    else if not shell.which cmd
      @error "#{cmd}: shell command not found"
    else
      cmd

  ## Returns all dirs between current workding directory
  ## and each dir's .wiz' directory.
  ##
  ## Returns an array of directories.
  wiz_option_dirs: ->
    dirs = []
    cwds = process.cwd().split(path.sep)
    while cwds.length > 0
      dir = cwds.join(path.sep) or '/'
      dirs.push dir
      dirs.push path.join(dir, ".wiz")
      break if dir is process.env['HOME']
      cwds.pop()
    dirs

  ## Search provided dirs for given filename.
  ## 
  ## Returns an array of directories that has the file.
  find_file: (file, dirs, cb) ->
    # search all candidate dirs at once
    # TODO: this code assumes returned filtered array
    # of directories with the file we're looking for
    # has
    async.filter dirs, (dir, cbdir) ->
      fullpath = path.join(dir, file)
      exists fullpath, cbdir
    , (filedirs) -> cb null, filedirs

  ## Parses a file containing general CLI options.
  ## Lines starting with '#' are ignored.
  ##
  ## Returns an array of option lines
  read_options: (file, cb) ->
    fs.readFile file,
      encoding: 'utf8'
    , (err, data) ->
      throw err if err
      cb null, data.split('\n').filter (line) ->
        # filter empty or comment lines
        line and line[0] isnt '#'

  ## Finds and reads *nearest* option file
  load_nearest_options: (file, cb) ->
    @find_file file, @wiz_option_dirs(), (err, filedirs) =>
      if filedirs.length > 0
        # top-most filedir is nearest
        @read_options path.join(filedirs[0], file), cb
      else
        cb null, []


argv = process.argv.slice(2)
wizcli = new WizCLI
  name: 'wiz'
wizcli.run argv.shift(), argv

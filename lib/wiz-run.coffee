exec = require('child_process').exec

module.exports = (args, cli, options) ->
  
  shell_cmd = cli.check_shell_command 'run', args.shift()
  wrapped_cmd = cli.check_shell_command 'run', args.shift()
  shell_cmd_option_file = "#{wrapped_cmd}.opts"
  
  # console.log "shell_cmd", shell_cmd
  # console.log "wrapped_cmd", wrapped_cmd
  # console.log "shell_cmd_option_file", shell_cmd_option_file

  cli.load_nearest_options shell_cmd_option_file, (err, opts) ->
    fullcmd = "#{shell_cmd} #{opts.join(' ').trim()} #{args.join(' ')}"
    # cli.echo fullcmd
    exec fullcmd, (err, stdout, stderr) ->
      console.error stderr if stderr
      console.log stdout if stdout
      if err
        cli.error err
      else
        cli.exit()

fs = require('fs')
path = require('path')

async = require('async')
mkdirp = require('mkdirp')

module.exports = (args, cli, options) ->
  shell_cmd = cli.check_shell_command 'curry', args.shift()
  wrapped_cmd = args.shift() or "z#{shell_cmd}"

  bin_dir = cli.get('bin_dir') or path.join(process.env['HOME'], ".wiz", "bin")  
  bin_file = path.join(bin_dir, wrapped_cmd)
  bin_script = "wiz run #{shell_cmd} #{wrapped_cmd} \"$@\""
  
  umask = if process.platform isnt "win32" then process.umask() else 0 
  mode = 0o777 & ~umask
  
  async.series [
    (done) ->
      # ensure `~/.wiz/curry` folder exists
      mkdirp path.dirname(bin_file), done
    (done) ->
      # write curry shell command file
      fs.writeFile bin_file, bin_script,
        mode: mode
      , done
  ], (err) ->
    if (err)
      cli.error err
    else
      cli.echo "created #{bin_file}"
      cli.exit()

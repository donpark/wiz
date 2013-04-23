fs = require('fs')
path = require('path')
exists = fs.exists or path.exists

async = require('async')

module.exports = (args, cli, options) ->
  curry_cmd = args.shift()
  cli.error "command to unlink not found" if not curry_cmd
  
  bin_dir = cli.get('bin_dir') or path.join(process.env['HOME'], ".wiz", "bin")  
  bin_file = path.join(bin_dir, curry_cmd)

  link_dir = cli.get('link_dir') or '/usr/local/bin'
  link_file = path.join(link_dir, curry_cmd)
  
  async.waterfall [
    (done) ->
      exists link_file, (exists) ->
        if not exists
          done "nothing to unlink at #{link_path}"
        else
          fs.lstat link_file, done
    (lstats, done) ->
      if not lstats.isSymbolicLink()
        done "#{link_file} is not a symlink"
      else
        done null
    (done) ->
      # drop symlink in global bin folder (/usr/local/bin)
      # TODO: resolve platform and configuration issues
      fs.unlink link_file, done
  ], (err) ->
    if (err)
      cli.error err
    else
      cli.echo "removed #{link_file}"
      cli.exit()

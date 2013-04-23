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
          # link_file doesn't exist, continue
          done null, null
        else
          # path is in use, see what it is
          fs.lstat link_file, done
    (lstats, done) ->
      if lstats and not lstats.isSymbolicLink()
        # it's not a symlink, can't link
        done "path #{link_file} is in use"
      else
        # link_file either doesn't exist or is already there and
        # assumed to be ours.
        # continue by checking if endpoint is there
        exists bin_file, (exists) ->
          if not exists
            # nothing to link to, abort
            done "nothing to link to at #{bin_file}"
          else
            done null
    (done) ->
      # drop symlink in global bin folder (/usr/local/bin)
      # TODO: resolve platform and configuration issues
      fs.symlink bin_file, link_file, "file", done
  ], (err) ->
    if (err)
      cli.error err
    else
      cli.echo "created #{link_file} -> #{bin_file}"
      cli.exit()

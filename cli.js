#!/usr/local/bin/node

// HACK: just calls `lib/wiz-cli` to workaround CoffeeScript emitting
// javascript comment "Generated by CoffeeScript 1.6.2" as first line
// which interfers with bash invoker above.

require('./lib/wiz-cli')

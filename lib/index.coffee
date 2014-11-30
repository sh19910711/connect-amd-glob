ConnectAmdGlob = require "./connect/middleware/connect_amd_glob"

callEntry = (options)->
  console.log "call_entry: ", "hello"
  return (req, res, next)->
    amd_glob = new ConnectAmdGlob(options)
    amd_glob.entry.apply amd_glob, arguments

module.exports = callEntry

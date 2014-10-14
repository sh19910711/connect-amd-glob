ConnectAmdGlob = require "./connect/middleware/connect_amd_glob"

call_entry = (options)->
  return (req, res, next)->
    amd_glob = new ConnectAmdGlob(options)
    amd_glob.entry.apply amd_glob, arguments

module.exports = call_entry

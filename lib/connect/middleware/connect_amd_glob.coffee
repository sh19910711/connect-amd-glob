class ConnectAmdGlob

  _ = require "lodash"
  mincer = require "mincer"

  DEFAULT_OPTIONS = {
    baseUrl: "/"
    workDir: process.cwd()
    path: ""
    assetPaths: []
  }

  constructor: (options)->
    @initOptions(options)
    @initMincer()

  initOptions: (options)->
    @options = {}
    _(@options).merge DEFAULT_OPTIONS
    _(@options).merge options

  initMincer: ->
    env = new mincer.Environment
    _(@options.assetPaths).each (asset_path)->
      console.log "initMincer: append #{asset_path}"
      env.appendPath asset_path
    console.log env.findAsset "file.js"

  startWithBaseUrl: (url)->
    regexp = new RegExp("^#{@options.baseUrl}")
    regexp.test url

  hasGlob: (url)->
    /\*/.test url

  isMatchURL: (url)->
    return false unless @startWithBaseUrl(url)
    return false unless @hasGlob(url)
    return true

  generateNamespaceScript: ->
    return [
      'define('

      # module paths
      '['
      '],'

      # module classes
      'function('
      ')'

      '{'

      # module namespace
      'function func() { return undefined; }'
      'func.prototype = {};'
      'return func;'

      '}'
      ');'
    ].join('')

  entry: (req, res, next)->
    if @isMatchURL(req.url)
      res.end @generateNamespaceScript()
    else
      next()

module.exports = ConnectAmdGlob

class ConnectAmdGlob

  _ = require "lodash"

  DEFAULT_OPTIONS = {
    baseUrl: "/"
    path: ""
  }

  constructor: (options)->
    @initOptions(options)

  initOptions: (options)->
    @options = {}
    _(@options).merge options
    _(@options).merge DEFAULT_OPTIONS

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

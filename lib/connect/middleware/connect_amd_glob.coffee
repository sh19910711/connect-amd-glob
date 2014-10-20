class ConnectAmdGlob

  _       = require "lodash"
  url     = require "url"
  mincer  = require "mincer"
  fs      = require "fs"
  glob    = require "glob"
  path    = require "path"

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
    @env = new mincer.Environment
    _(@options.assetPaths).each (assetPath)=>
      @env.appendPath assetPath

  startWithBaseUrl: (url)->
    regexp = new RegExp("^#{@options.baseUrl}")
    regexp.test url

  hasGlob: (url)->
    /\*/.test url

  isMatchURL: (url)->
    return false unless @startWithBaseUrl(url)
    return false unless @hasGlob(url)
    return true

  removeFileExtension: (name)->
    name.slice(0, -1 * path.extname(name).length)

  capitalize: (name)->
    name.charAt(0).toUpperCase() + name.slice(1)

  getModulePaths: (files)->
    paths = []
    module_paths = files
      .map @removeFileExtension
      .map (filename)->
        "'./#{filename}'"
    module_paths

  getModuleClassNames: (files)->
    class_names = files
      .map @removeFileExtension
      .map @capitalize
    class_names

  getProp: (parent)->
    return (name)=>
      "func.#{@capitalize(name)} = #{@capitalize(name)};"

  getPrototype: (parent)->
    return (name)=>
      "func.prototype.#{@capitalize(name)} = #{@capitalize(name)};"

  getModuleNamespaces: (parent, files)->
    props = files
      .map @removeFileExtension
      .map @capitalize
      .map @getProp(parent)

    prototypes = files
      .map @removeFileExtension
      .map @capitalize
      .map @getPrototype(parent)

    props.concat prototypes

  generateNamespaceScript: (parent, files)->
    return [
      'define('

      # module paths
      '['
      @getModulePaths(files).join(",")
      '],'

      # module classes
      'function('
      @getModuleClassNames(files).join(",")
      ')'

      '{'

      # module namespace
      'function func() { return undefined; }'
      'func.prototype = {};'
      @getModuleNamespaces(parent, files).join("")
      'return func;'

      '}'
      ');'
    ].join('')

  removeBaseURL: (target_path)->
    target_path.substr @options.baseUrl.length

  getRealPath: (base_path, target_path)->
    path.join(@options.workDir, base_path, @removeBaseURL(target_path)).toString()

  findDirectory: (url_str)->
    result_path = undefined
    url_obj = url.parse(url_str)
    path_str = url_obj.pathname
    _(@options.assetPaths).each (asset_path)=>
      real_path = @getRealPath(asset_path, path_str)
      dir_path = path.dirname(real_path)
      if fs.existsSync(dir_path)
        result_path = dir_path
    result_path

  getFiles: (dir_path)->
    glob.sync("#{dir_path}/*").map (file_path)->
      path.basename(file_path)

  getParent: (target_path)->
    target_path_without_base = target_path.substr(@options.baseUrl.length)
    path.basename(path.dirname(target_path_without_base))

  entry: (req, res, next)->
    if @isMatchURL(req.url)
      dir_path = @findDirectory(req.url)
      return next() unless dir_path
      target_files = @getFiles(dir_path)
      parent_name = @getParent(req.url)
      script_src = @generateNamespaceScript(parent_name, target_files)
      res.end script_src
    else
      next()

module.exports = ConnectAmdGlob

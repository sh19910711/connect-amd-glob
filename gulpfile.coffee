gulp    = require "gulp"
debug   = require "gulp-debug"
mocha   = require "gulp-mocha"
concat  = require "gulp-concat"
coffee  = require "gulp-coffee"
remoteSrc     = require "gulp-remote-src"
amdOptimizer  = require "gulp-amd-optimizer"

gulp.task "test", ->
  gulp.src ["spec/**/*_spec.coffee"]
    .pipe mocha()

gulp.task "watch", ->
  gulp.watch(
    [
      "spec/**/*.coffee"
      "lib/**"
    ]
    [
      "test"
    ]
  )

gulp.task "server", (cb)->
  app = require("connect")()
  app.use require("./lib")(
    assetPaths: [
      "spec/fixtures/assets/coffee"
    ]
  )
  require("http").createServer(app).listen(19292, "127.0.0.1")
  return undefined

gulp.task "app.js", ->
  remoteSrc ["app.js"], {base: "http://localhost:19292/"}
    .pipe debug(verbose: true)
    .pipe amdOptimizer(
      "app"
      {
        configFile: gulp.src("spec/requirejs_config.coffee").pipe(coffee())
      }
    )
    .pipe concat("app.js")
    .pipe gulp.dest("tmp/")

gulp.task "default", ["test"]


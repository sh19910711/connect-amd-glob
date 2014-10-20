gulp = require "gulp"
mocha = require "gulp-mocha"
amd_optimizer = require "gulp-amd-optimizer"
concat = require "gulp-concat"

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

gulp.task "requirejs/server", ->
  app = require("connect")()
  app.use require("./lib")(
    assetPaths: [
      "spec/fixtures/assets/coffee"
    ]
  )
  server = require("http").createServer(app).listen(19292, "127.0.0.1")
  return undefined

gulp.task "requirejs", ->
  base_url = "http://localhost:19292"
  gulp.src(["spec/fixtures/assets/coffee/main.js"], {base: base_url})
    .pipe amd_optimizer({baseUrl: base_url}, {})
    .pipe concat("app.js")
    .pipe gulp.dest("tmp/")

gulp.task "default", ["test"]


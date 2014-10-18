proxyquire = require "proxyquire"
proxyquire.noPreserveCache()
mock_fs = require "mock-fs"

dummy_fs = mock_fs.fs()

mkdirp = proxyquire(
  "mkdirp"
  {
    "fs": dummy_fs
  }
)

glob = proxyquire(
  "glob"
  {
    "fs": dummy_fs
    "graceful-fs": dummy_fs
  }
)

mkdirp.sync "path/to"
dummy_fs.writeFileSync "path/to/file.coffee", 'console.log "dummy"'
console.log "create fs"


connect = require "connect"

http    = require "http"
request = require "supertest"
jslint  = require "jslint"
stream  = require "stream"
chai    = require "chai"
expect  = chai.expect

describe "ConnectAmdGlob", ->

  context "create app", ->

    before ->
      @app = connect()

    context "use connect_amd_glob", ->

      before ->
        console.log "register mock"
        mockery = require "mockery"
        mockery.registerMock "./common", {
        }
        mockery.enable()
        mockery.warnOnReplace(false)
        mockery.warnOnUnregistered(false)
        dummy_trail = proxyquire(
          "../../node_modules/hike/lib/hike/trail"
          {
            "./common": proxyquire(
              "../../node_modules/hike/lib/hike/common"
              {
                fs: "hey"
              }
            )
          }
        )
        mockery.registerMock "hike", class DummyHike
          @Trail: dummy_trail
        console.log("require connect_amd_glob");
        connect_amd_glob = proxyquire(
          "../../lib/index"
          {
          }
        )


        @app.use connect_amd_glob(
          assetPaths: [
            "path/to"
          ]
        )

      context "run http server", ->

        before ->
          @server = http.createServer(@app).listen(0, "127.0.0.1")

        after ->
          @server.close()

        context "GET /hello", ->

          beforeEach ->
            @req = request(@server)
              .get "/hello"

          it "is 404", (done)->
            @req.expect 404, done

        context "GET /hello/*.js", ->

          beforeEach ->
            @req = request(@server)
              .get "/hello/*.js"

          it "is 200", (done)->
            @req.expect 200, done

          it "returns a valid script", (done)->
            @req
              .expect (req)->
                ls = new jslint.LintStream(
                  sloppy: true
                  empty_block: true
                  white: true
                )
                ls.on "data", (chunk, enc, next)->
                  # console.log chunk.linted
                  expect(chunk.linted.ok).to.be.ok
                ls.write(
                  file: "hello"
                  body: "function define() { return 'define'; } #{req.text}"
                )
                return false
              .end done


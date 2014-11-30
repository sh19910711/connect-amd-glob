connect = require "connect"
connect_amd_glob = require "../../lib/index"

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
        @app.use connect_amd_glob(
          baseUrl: "/amd_glob"
          assetPaths: [
            "spec/fixtures/assets/coffee"
          ]
        )

      context "run http server", ->

        before ->
          @server = http.createServer(@app).listen(0, "127.0.0.1")

        after ->
          @server.close()

        context "GET /amd_glob", ->

          beforeEach ->
            @req = request(@server)
              .get "/amd_glob"

          it "is 404", (done)->
            @req.expect 404, done

        context "GET /amd_glob/*.js", ->

          beforeEach ->
            @req = request(@server)
              .get "/amd_glob/*.js"

          it "is 200", (done)->
            @req.expect 200, done

          it "returns a valid script", (done)->
            @req
              .expect (req)->
                linter = new jslint.LintStream(
                  sloppy: true
                  empty_block: true
                  white: true
                )
                linter.on "data", (chunk, enc, next)->
                  # console.log chunk.linted
                  expect(chunk.linted.ok).to.be.ok
                linter.write(
                  file: "hello"
                  body: "function define() { return 'define'; } #{req.text}"
                )
                return false
              .end done


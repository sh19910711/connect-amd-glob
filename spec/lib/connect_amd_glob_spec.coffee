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
        @app.use connect_amd_glob()

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


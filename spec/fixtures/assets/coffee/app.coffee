define(
  ["./hello", "./sub_hello/*"]
  (Hello, SubHello)->
    class Application
      initialize: ->
        hello = new Hello
)

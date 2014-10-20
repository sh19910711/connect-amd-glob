define(["./sub_hello/*"], function() {
  var func = function() {
  };
  func.prototype = {
    hello: function() {
      console.log("hello");
    }
  };
  return func;
});

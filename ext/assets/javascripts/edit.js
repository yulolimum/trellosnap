// Generated by CoffeeScript 1.8.0
(function() {
  this.Handlers = (function() {
    function Handlers() {}

    return Handlers;

  })();

  chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    return console.log(message.image);
  });

}).call(this);

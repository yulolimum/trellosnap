// Generated by CoffeeScript 1.8.0
(function() {
  var Events, Handlers;

  Events = (function() {
    function Events() {}

    Events.bind_capture_visible = function(button) {
      return button.on("click", function() {
        return Handlers.capture_visible_screenshot();
      });
    };

    Events.bind_capture_partial = function(button) {
      return button.on("click", function() {
        return Handlers.capture_partial_screenshot();
      });
    };

    return Events;

  })();

  jQuery(function() {
    if ($("#capture-visible").length) {
      Events.bind_capture_visible($("#capture-visible"));
    }
    if ($("#capture-partial").length) {
      return Events.bind_capture_partial($("#capture-partial"));
    }
  });

  Handlers = (function() {
    function Handlers() {}

    Handlers.edit_page_path = "/views/edit.html";

    Handlers.page_info = function() {
      return {
        browser: "mozilla",
        resolution: "500x400"
      };
    };

    Handlers.capture_visible_screenshot = function() {
      return chrome.tabs.captureVisibleTab(void 0, {
        format: "png"
      }, (function(_this) {
        return function(image) {
          return _this.open_edit_tab(image);
        };
      })(this));
    };

    Handlers.open_edit_tab = function(image) {
      return chrome.tabs.create({
        url: this.edit_page_path
      }, (function(_this) {
        return function(tab) {
          return chrome.tabs.sendMessage(tab.id, {
            image: image,
            page: _this.page_info()
          });
        };
      })(this));
    };

    Handlers.capture_partial_screenshot = function() {
      return chrome.tabs.insertCSS(null, {
        file: "/assets/stylesheets/selection.css"
      }, (function(_this) {
        return function() {
          return chrome.tabs.executeScript(null, {
            file: "/assets/javascripts/vendor/jquery.min.js"
          }, function() {
            return chrome.tabs.executeScript(null, {
              file: "/assets/javascripts/selection.js"
            }, function() {
              return window.close();
            });
          });
        };
      })(this));
    };

    return Handlers;

  })();

}).call(this);
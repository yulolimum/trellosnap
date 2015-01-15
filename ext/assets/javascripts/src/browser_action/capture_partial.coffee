class CapturePartial

  @screenshot = ->
    chrome.tabs.insertCSS null, {file: "/assets/stylesheets/selection.css"}, () =>
      chrome.tabs.executeScript null, {file: "/assets/javascripts/vendor/jquery.min.js"}, () =>
        chrome.tabs.executeScript null, {file: "/assets/javascripts/selection.js"}, () =>
          window.close()
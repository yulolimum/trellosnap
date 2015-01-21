class CaptureVisible

  edit_page_path = "/views/edit.html"

  @screenshot = ->
    chrome.tabs.executeScript null, {code: "document.URL"}, (page_url) ->
      chrome.tabs.executeScript null, {code: "var res = window.innerWidth + ' x ' + window.innerHeight; res"}, (page_resolution) ->
        chrome.tabs.captureVisibleTab undefined, {format: "png"}, (image) ->
          open_edit_tab image, page_info page_url[0], page_resolution[0]

  page_info = (url, res) ->
    url            : url
    resolution     : res
    retina         : if devicePixelRatio == 2 then "yes" else "no"
    chrome_version : window.navigator.appVersion.match(/Chrome\/(.*?) /)[1];

  open_edit_tab = (image, page_info) ->
    chrome.tabs.create
      url: edit_page_path
      (tab)=>
        chrome.tabs.sendMessage tab.id, {image: image, page: page_info, screenshot: "visible"}
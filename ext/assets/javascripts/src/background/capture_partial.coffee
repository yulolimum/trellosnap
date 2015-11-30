class BGCapturePartial

  edit_page_path = "/views/edit.html"

  @screenshot = (image_info)->
    chrome.tabs.executeScript null, {code: "document.URL"}, (page_url) ->
      chrome.tabs.executeScript null, {code: "var res = window.innerWidth + ' x ' + window.innerHeight; res"}, (page_resolution) ->
        chrome.tabs.captureVisibleTab undefined, {format: "png"}, (image) ->
          open_edit_tab image, image_info, page_info page_url[0], page_resolution[0]

  page_info = (url, res) ->
    url            : url
    resolution     : res
    retina         : if devicePixelRatio == 2 then "yes" else "no"
    chrome_version : window.navigator.appVersion.match(/Chrome\/(.*?) /)[1];

  open_edit_tab = (image, image_info, page_info) ->
    chrome.tabs.create
      url: edit_page_path
      (tab)=>
        chrome.tabs.sendMessage tab.id, {image: image, image_info: image_info, page: page_info, screenshot: "partial"}
        window.close()

chrome.runtime.connect()

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  BGCapturePartial.screenshot request.image_info if request.capture
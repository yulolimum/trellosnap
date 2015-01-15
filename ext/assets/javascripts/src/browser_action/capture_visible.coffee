class CaptureVisible

  edit_page_path = "/views/edit.html"

  @screenshot = ->
    chrome.tabs.captureVisibleTab undefined, {format: "png"}, (image) =>
      open_edit_tab image

  page_info = ->
    # to do
    browser: "mozilla"
    resolution: "500x400"

  open_edit_tab = (image) ->
    chrome.tabs.create
      url: edit_page_path
      (tab)=>
        chrome.tabs.sendMessage tab.id, {image: image, page: page_info(), screenshot: "visible"}
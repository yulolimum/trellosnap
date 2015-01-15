class BGCapturePartial

  edit_page_path = "/views/edit.html"

  @screenshot = (image_info)->
    chrome.tabs.captureVisibleTab undefined, {format: "png"}, (image) =>
      open_edit_tab image, image_info

  page_info = ->
    # to do
    browser: "mozilla"
    resolution: "500x400"

  open_edit_tab = (image, image_info) ->
    chrome.tabs.create
      url: edit_page_path
      (tab)=>
        chrome.tabs.sendMessage tab.id, {image: image, image_info: image_info, page: page_info(), screenshot: "partial"}

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  BGCapturePartial.screenshot request.image_info if request.capture
class Handlers

  @edit_page_path = "/views/edit.html"

  @page_info = ->
    # to do
    browser: "mozilla"
    resolution: "500x400"

  @capture_visible_screenshot = ->
    chrome.tabs.captureVisibleTab undefined, {format: "png"}, (image) =>
      this.open_edit_tab image

  @open_edit_tab = (image) ->
    chrome.tabs.create
      url: this.edit_page_path
      (tab)=>
        chrome.tabs.sendMessage tab.id, {image: image, page: this.page_info()}
class Edit

  @screenshot = (type, image_url, image_info={}) ->
    $image = new Image
    $image.src = image_url
    $image.onload = ()->
      jQuery ->
        if type == "visible"
          $("main").append canvas_html image_url, $image.naturalWidth, $image.naturalHeight, 0, 0
        else if type == "partial"
          $("main").append canvas_html image_url, image_info.w, image_info.h, image_info.x, image_info.y
        $image_canvas = $("#canvas-image")
        context = $image_canvas[0].getContext('2d')
        context.scale(2,2)
        if type == "visible"
          context.drawImage $image, 0, 0
        else if type == "partial"
          context.drawImage $image, image_info.x, image_info.y, image_info.w, image_info.h, 0, 0, image_info.w, image_info.h

  canvas_html = (image_url, w, h, x, y) ->
    """
      <section id="editor">
        <canvas id="canvas-image" width="#{w}" height="#{h}"></canvas>
        <canvas id="canvas-annotations" width="#{w}" height="#{h}"></canvas>
      </section>

      <style>
        #editor {
          width      : #{w}px;
          height     : #{h}px;
          background : url(#{image_url}) no-repeat -#{x}px -#{y}px;
        }

        main {
          min-width: #{w+100}px;
        }
      </style>
    """

chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  Edit.screenshot message.screenshot, message.image, message.image_info

jQuery ->
  $("main").css
    "min-height": $(window).innerHeight() - 70
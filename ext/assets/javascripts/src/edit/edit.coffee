class Edit

  @screenshot = (type, image_url, image_info={}) ->
    $image = new Image
    $image.src = image_url
    $image.onload = ()->
      jQuery ->
        append_canvas_html type, image_url, image_info, $image
        $image_canvas = $("#canvas-image")
        context = $image_canvas[0].getContext('2d')
        # context.scale(2,2)
        draw_image_to_canvas type, $image, image_info, context
        annotate_canvas $("#canvas-annotations")

  draw_image_to_canvas = (type, $image, image_info={}, context) ->
    if type == "visible"
      context.drawImage $image, 0, 0
    else if type == "partial"
      context.drawImage $image, image_info.x, image_info.y, image_info.w, image_info.h, 0, 0, image_info.w, image_info.h

  append_canvas_html = (type, image_url, image_info={}, $image) ->
    if type == "visible"
      $("main").append canvas_html image_url, $image.naturalWidth, $image.naturalHeight, 0, 0
    else if type == "partial"
      $("main").append canvas_html image_url, image_info.w, image_info.h, image_info.x, image_info.y

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

  annotate_canvas = ($canvas)->
    $canvas.annotate
      tools_container : "#header-main #annotate"
      color           : 'red'
      type            : 'rectangle'

  save_canvas = ->
    screenshot     = $("#canvas-image")
    screenshot_ctx = screenshot[0].getContext("2d")
    annotations    = $("#canvas-annotations")
    screenshot_ctx.drawImage(annotations[0], 0, 0)
    image          = screenshot[0].toDataURL("image/png")
    return image

  blob = (data_image) ->
    binary = atob(data_image.split(",")[1])
    array = []
    i = 0
    while i < binary.length
      array.push binary.charCodeAt(i)
      i++
    new Blob([new Uint8Array(array)],
      type: "image/png"
    )

  @init_trello = ->
    Trello.is_user_logged_in (username) ->
      if username
        Trello.get_api_credentials (creds) ->
          if creds
            Trello.get_client_token creds, (token) ->
              if token
                access = {username: username, creds: creds, token: token}
                build_trello_boards access
                bind_trello access
      else
        # show log in form
        callback false

  bind_trello = (access)->
    $("#trello-boards select").on "change", ->
      update_select_field  $(this)
      build_trello_lists  $(this).find("option:selected").val(), access
      build_trello_labels $(this).find("option:selected").val(), access
    $("#trello-lists select").on "change", ->
      update_select_field  $(this)
    $("#trello-labels").on "click", "> div", ->
      $(this).toggleClass "selected"
    $("#trello-card-submit").on "click", ->
      submit_trello_card access, $("#trello-card-name").val(), $("#trello-card-description").val(), $("#trello-lists select option:selected").val(), get_selected_labels(), $("#trello-card-position").prop("checked"), blob(save_canvas())

  build_trello_boards = (access) ->
    Trello.get_boards access, (boards) ->
      if boards.length
        for board in boards
          $("#trello-boards select").append "<option value='#{board.id}'>#{board.name}</option>"
          $("#trello-boards select").trigger "change"

  build_trello_lists = (board_id, access) ->
    Trello.get_lists board_id, access, (lists) ->
      if lists.length
        $("#trello-lists select").empty()
        for list in lists
          $("#trello-lists select").append "<option value='#{list.id}'>#{list.name}</option>"
          $("#trello-lists select").trigger "change"

  build_trello_labels = (board_id, access) ->
    label_colors = ["black","blue","green","lime","orange","pink","purple","red","sky","yellow"]
    $("#trello-labels > div").not(".trello-label-description").empty()
    Trello.get_labels board_id, access, (labels) ->
      if labels
        for color in label_colors
          $("#trello-labels .trello-label-#{color}").text labels[color]

  submit_trello_card = (access, name, description, list, labels, position, blob) ->
    Trello.submit_card access, name, description, list, labels, (card) ->
      Trello.move_card_to_top  access, card.id if card && position
      if card && blob
        Trello.upload_attachment access, card.id, blob, (data) ->
          alert "successfully uploaded image" if data.isUpload

  update_select_field = ($select) ->
    $select.parent().find(".input").text $select.find("option:selected").text()

  get_selected_labels = ->
    array = []
    $("#trello-labels").find(".selected").each ->
      array.push $(this).data("trello-color")
    return array.join(",")


chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  Edit.screenshot message.screenshot, message.image, message.image_info

jQuery ->
  Edit.init_trello()

  $("main").css
    "min-height": $(window).innerHeight() - 70

  $("#upload").on "click", ".upload-button", ->
     # open trello


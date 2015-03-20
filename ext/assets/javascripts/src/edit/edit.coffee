class Edit
  page_info = ""

  @prepare_page_info = (page_information) ->
    page_info += "\n\n----------\n\n"
    for name, value of page_information
      page_info += "#{name}: #{value}\n"

  @screenshot = (type, image_url, image_info={}) ->
    $image = new Image
    $image.src = image_url
    $image.onload = ()->
      jQuery ->
        append_canvas_html type, image_url, image_info, $image
        $image_canvas = $("#canvas-image")
        context = $image_canvas[0].getContext('2d')
        draw_image_to_canvas type, $image, image_info, context
        annotate_canvas $("#canvas-annotations")

  draw_image_to_canvas = (type, $image, image_info={}, context) ->
    if type == "visible"
      context.drawImage $image, 0, 0, $image.naturalWidth/devicePixelRatio, $image.naturalHeight/devicePixelRatio
    else if type == "partial"
      context.drawImage $image, image_info.x*devicePixelRatio, image_info.y*devicePixelRatio, image_info.w*devicePixelRatio, image_info.h*devicePixelRatio, 0, 0, image_info.w, image_info.h

  append_canvas_html = (type, image_url, image_info={}, $image) ->
    if type == "visible"
      $("#editor-container").append canvas_html image_url, $image.naturalWidth/devicePixelRatio, $image.naturalHeight/devicePixelRatio, 0, 0, $image.naturalWidth/devicePixelRatio, $image.naturalHeight/devicePixelRatio
    else if type == "partial"
      $("#editor-container").append canvas_html image_url, image_info.w, image_info.h, image_info.x, image_info.y, $image.naturalWidth/devicePixelRatio, $image.naturalHeight/devicePixelRatio

  canvas_html = (image_url, w, h, x, y, bg_w, bg_h) ->
    """
      <div id="editor">
        <canvas id="canvas-image" width="#{w}" height="#{h}"></canvas>
        <canvas id="canvas-annotations" width="#{w}" height="#{h}"></canvas>
      </div>

      <style>
        #editor {
          width           : #{w}px;
          height          : #{h}px;
          background      : url(#{image_url}) no-repeat -#{x}px -#{y}px;
          background-size: #{bg_w}px #{bg_h}px;
        }

        #editor-container {
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
        $("#login-container").hide()
        $("#card-status-picker, #add-card-container").show()
        Trello.get_api_credentials (creds) ->
          if creds
            Trello.get_client_token creds, (token) ->
              if token
                access = {username: username, creds: creds, token: token}
                $(".trello-card-position input").prop "checked", true if localStorage.position == "true"
                build_trello_boards access
                bind_trello access
      else
        $("#login-container").show()
        $("#card-status-picker, #add-card-container").hide()
        window.setTimeout ->
          Edit.init_trello()
        , 2000

  bind_trello = (access)->
    $("#trello-boards select").on "change", ->
      update_select_field  $(this)
      build_trello_lists  $(this).find("option:selected").val(), access
      build_trello_labels $(this).find("option:selected").val(), access

    $("#trello-lists select").on "change", ->
      update_select_field  $(this)
      build_trello_cards   $(this).find("option:selected").val(), access

    $("#trello-labels").on "click", "> div", ->
      $(this).toggleClass "selected"

    $("#trello-card-picker").on "click", ".card", ->
      $(this).siblings().removeClass("selected")
      $(this).addClass "selected"
      update_trello_labels $(this).data("card-id"), access

    $("#trello-card-submit").on "click", ->
      validate_card_info (validated) ->
        if validated
          save_preferences_to_storage()
          $("#trello-card-submit").prop "disabled", true
          $("#trello-upload-progress").show()
          submit_trello_card(
            access,
            $("#trello-card-name").val(),
            $("#trello-card-description").val() + page_info,
            $("#trello-lists select option:selected").val(),
            $("#trello-card-picker").find(".selected").data("card-id"),
            get_selected_labels(),
            $(".trello-card-position:visible input").is(":checked"),
            blob(save_canvas())
          )

  build_trello_boards = (access) ->
    Trello.get_boards access, (boards) ->
      if boards.length
        for board in boards
          $("#trello-boards select").append "<option value='#{board.id}' #{if board.id == localStorage.board then "selected" else ""}>#{board.name}</option>"
        $("#trello-boards select").trigger "change"

  build_trello_lists = (board_id, access) ->
    Trello.get_lists board_id, access, (lists) ->
      if lists.length
        $("#trello-lists select").empty()
        for list in lists
          $("#trello-lists select").append "<option value='#{list.id}' #{if list.id == localStorage.list then "selected" else ""}>#{list.name}</option>"
        $("#trello-lists select").trigger "change"

  build_trello_cards = (list_id, access) ->
    Trello.get_cards list_id, access, (cards) ->
      $("#trello-card-picker .scrollable-card-list").empty()
      if cards.length
        for card in cards
          unless card.closed
            $("#trello-card-picker .scrollable-card-list").append "<span class='card' data-card-id='#{card.id}'><div class='name'>#{card.name}</div><div class='description'>#{card.desc}</div></span>"
        $("#trello-card-picker .scrollable-card-list").perfectScrollbar("destroy").perfectScrollbar
          suppressScrollX    : true
          maxScrollbarLength : '20'
          wheelPropagation   : true
        $("#trello-card-picker .description").dotdotdot
          watch: "window"
      else
        $("#trello-card-picker .scrollable-card-list").append "<div class='error'>There are no cards in this list.</div>"

  build_trello_labels = (board_id, access) ->
    label_colors = ["black","blue","green","lime","orange","pink","purple","red","sky","yellow"]
    $("#trello-labels > div").not(".trello-label-description").empty()
    Trello.get_labels board_id, access, (labels) ->
      if labels
        for color in label_colors
          $("#trello-labels .trello-label-#{color}").text labels[color]

  update_trello_labels = (card_id, access) ->
    Trello.get_card_labels card_id, access, (labels) ->
      if labels
        for label in labels
          $("#trello-labels .trello-label-#{label.color}").addClass "selected"

  submit_trello_card = (access, name, description, list_id, card_id=null, labels, position, blob) ->
    if card_id == null
      Trello.submit_card access, name, description, list_id, labels, (card) ->
        move_card_and_attach_image access, card.id, position, blob, card.shortUrl
    else
      move_card_and_attach_image access, card_id, position, blob

  move_card_and_attach_image = (access, card_id, position, blob, card_url=null) ->
    Trello.move_card_to_top access, card_id if card_id && position
    if card_id && blob
      Trello.upload_attachment access, card_id, blob, (data) ->
        if data.isUpload
          $("#trello-upload-progress").hide()
          if card_url
            $("#trello-upload-success").show().append(" Here's a link to the card: <div class='url'><a href='#{card_url}'>#{card_url}</a></div>")
          else
            $("#trello-upload-success").show().append("<div class='url'>Your image was successfully added to the card!</div>")
        else
          alert "Upload failed. Please try again."

  update_select_field = ($select) ->
    $select.parent().find(".input").text $select.find("option:selected").text()

  get_selected_labels = ->
    array = []
    $("#trello-labels").find(".selected").each ->
      array.push $(this).data("trello-color")
    return array.join(",")

  validate_card_info = (callback) ->
    validations = []
    # 1
    validations.push if $("#trello-boards select").val() == "" then false else true
    # 2
    validations.push if $("#trello-lists select").val() == "" then false else true
    # 3
    validations.push(if $("#trello-card-name").val() == "" then false else true) unless $("#card-status-picker").hasClass "existing-card"
    validations.push(unless $("#trello-card-picker").find(".selected").length then false else true) if $("#card-status-picker").hasClass "existing-card"
    append_errors validations
    callback if validations.indexOf(false) == -1 then true else false

  append_errors = (errors=[]) ->
    $val = $("#trello-validation")
    $val.empty()
    $val.append "<div class='error'>Please select a board before submitting.</div>"    if !errors[0]
    $val.append "<div class='error'>Please select a list before submitting.</div>"     if !errors[1]
    if $("#card-status-picker").hasClass "existing-card"
      $val.append "<div class='error'>Please select a card before submitting.</div>"   if !errors[2]
    else
      $val.append "<div class='error'>Please add a card name before submitting.</div>" if !errors[2]

  save_preferences_to_storage = ->
    localStorage.board     = $("#trello-boards select option:selected").val()
    localStorage.list      = $("#trello-lists select option:selected").val()
    localStorage.position  = $(".trello-card-position:visible input").is(":checked")


  # card status
  @pick_card_status = ($switcher) ->
    if $switcher.hasClass "existing-card"
      $switcher.removeClass "existing-card"
      prepare_uploader_for_new_card()
    else
      $switcher.addClass "existing-card"
      prepare_uploader_for_existing_card()

  prepare_uploader_for_new_card = ->
    $("#trello-board-info .section-title").empty().text "Boards / Lists / Labels"
    $("#trello-card-info, #trello-labels").show()
    $("#trello-card-picker").hide()

  prepare_uploader_for_existing_card = ->
    $("#trello-board-info .section-title").empty().text "Select Board and List"
    $("#trello-card-info, #trello-labels").hide()
    $("#trello-card-picker").show()

chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  Edit.screenshot message.screenshot, message.image, message.image_info
  Edit.prepare_page_info message.page

jQuery ->
  Edit.init_trello()

  canvas_size = setInterval ->
    if $(window).innerHeight() > 0
      clearInterval canvas_size
      $("#editor-container").css "min-height", ($(window).innerHeight() - 70 + "px")
  , 50

  $("#card-status-picker").on "click", ("#switcher, .description-left, .description-right"), ->
    Edit.pick_card_status $("#card-status-picker")

  $("#upload").on "click", ".upload-button", ->
    $trello = $("#trello")
    if $trello.is ":visible"
      if $("#trello-card-name").val() != "" && $("#trello-boards select").val() != "" && $("#trello-lists select").val() != "" && !$("#trello-card-submit").is(':disabled')
        $("#trello-card-submit").trigger "click"
      else
        $("#trello").slideUp 200
    else
     $("#trello").slideDown 200
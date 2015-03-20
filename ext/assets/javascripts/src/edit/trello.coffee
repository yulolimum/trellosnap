class Trello

  @is_user_logged_in = (callback) ->
    $.ajax
      url: "https://trello.com/1/Members/me"
    .done (data)->
      callback data.username
    .fail ->
      callback false

  @get_api_credentials = (callback) ->
    $.ajax
      url: "https://trello.com/1/appKey/generate"
    .done (data)->
      $html = $($.parseHTML data)
      callback
        api_key    : $html.find("input#key").val()
        api_secret : $html.find("input#secret").val()
    .fail ->
      callback false

  @get_client_token = (creds, callback) ->
    $.ajax
      url: "https://trello.com/1/authorize?key=#{creds.api_key}&name=TrelloCapture&expiration=never&response_type=token&scope=read,write"
    .done (data)->
      $html = $($.parseHTML data)
      $.ajax
        type : 'POST'
        url  : 'https://trello.com/1/token/approve'
        data : { approve: "Allow", requestKey: $html.find("input[name='requestKey']").val(), signature: $html.find("input[name='signature']").val() }
      .done (data)->
        $html = $($.parseHTML data)
        token = $($html[5]).html().replace(RegExp(" ", "g"), "").replace(/\r\n/g, "").replace(/\n/g, "").replace /\r/g, ""
        if token && token.length == 64
          callback token
        else
          callback false
      .fail ->
        callback false
    .fail ->
      callback false

  @get_boards = (access, callback) ->
    $.ajax
      url: "https://api.trello.com/1/members/#{access.username}/boards?key=#{access.creds.api_key}&token=#{access.token}"
    .done (data)->
      callback(data.filter (board)->
        !board.closed
      )
    .fail ->
      callback false

  @get_lists = (board_id, access, callback) ->
    $.ajax
      url: "https://api.trello.com/1/boards/#{board_id}/lists?key=#{access.creds.api_key}&token=#{access.token}"
    .done (data)->
      callback(data.filter (list)->
        !list.closed
      )
    .fail ->
      callback false

  @get_labels = (board_id, access, callback) ->
    $.ajax
      url: "https://api.trello.com/1/boards/#{board_id}/labelNames?key=#{access.creds.api_key}&token=#{access.token}"
    .done (data)->
      callback data
    .fail ->
      callback false

  @get_card_labels = (card_id, access, callback) ->
    $.ajax
      url: "https://api.trello.com/1/cards/#{card_id}/labels?key=#{access.creds.api_key}&token=#{access.token}"
    .done (data)->
      callback data
    .fail ->
      callback false

  @get_cards = (list_id, access, callback) ->
    $.ajax
      url: "https://api.trello.com/1/lists/#{list_id}/cards?key=#{access.creds.api_key}&token=#{access.token}"
    .done (data)->
      callback data
    .fail ->
      callback false

  @submit_card = (access, name, description, list_id, labels, callback) ->
    labels = if labels.length then "&labels=#{labels}" else ""
    $.ajax
      url  : "https://api.trello.com/1/lists/#{list_id}/cards?key=#{access.creds.api_key}&token=#{access.token}#{labels}"
      type : "POST"
      data : { name: name, desc: description, pos: "top" }
    .done (data)->
      callback data
    .fail ->
      callback false

  @move_card_to_top = (access, card_id) ->
    $.ajax
      url  : "https://api.trello.com/1/cards/#{card_id}?key=#{access.creds.api_key}&token=#{access.token}"
      type : "PUT"
      data : { pos: "top" }

  @upload_attachment = (access, card_id, blob, callback) ->
    form_data = new FormData()
    form_data.append("file", blob, "trellosnap-screenshot.png")
    $.ajax
      url         : "https://api.trello.com/1/cards/#{card_id}/attachments?key=#{access.creds.api_key}&token=#{access.token}"
      type        : "POST"
      data        : form_data
      processData : false
      contentType : false
    .done (data)->
      callback data
    .fail ->
      callback false
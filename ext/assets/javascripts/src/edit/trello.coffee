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
class Actions

  @bind_capture_visible = ($button) ->
    $button.on "click", ->
      CaptureVisible.screenshot()

  @bind_capture_partial = ($button) ->
    $button.on "click", ->
      CapturePartial.screenshot()

  @bind_info_button = ($button) ->
    $button.on "click", ->
      $more_info = $button.siblings(".more-info-container")
      if $button.hasClass "active"
        $button.removeClass "active"
        $more_info.slideUp 150
      else
        $button.addClass "active"
        $more_info.slideDown 150

jQuery ->

  # capture visible button
  Actions.bind_capture_visible $("#capture-visible") if $("#capture-visible").length

  # capture partial button
  Actions.bind_capture_partial $("#capture-partial") if $("#capture-partial").length

  # capture info button
  Actions.bind_info_button     $("#more-info-icon")  if $("#more-info-icon").length
class Actions

  @bind_capture_visible = (button) ->
    button.on "click", ->
      CaptureVisible.screenshot()

  @bind_capture_partial = (button) ->
    button.on "click", ->
      CapturePartial.screenshot()

jQuery ->

  # capture visible button
  Actions.bind_capture_visible $("#capture-visible") if $("#capture-visible").length

  # capture partial button
  Actions.bind_capture_partial $("#capture-partial") if $("#capture-partial").length
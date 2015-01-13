class Events

  @bind_capture_visible = (button) ->
    button.on "click", ->
      Handlers.capture_visible_screenshot()

  @bind_capture_partial = (button) ->
    button.on "click", ->
      Handlers.capture_partial_screenshot()

jQuery ->

  # capture visible button
  Events.bind_capture_visible $("#capture-visible") if $("#capture-visible").length

  # capture partial button
  Events.bind_capture_partial $("#capture-partial") if $("#capture-partial").length
class @Handlers



chrome.runtime.onMessage.addListener (message, sender, sendResponse) ->
  console.log message.image

  # CODE FOR PARIAL IMAGE
  # jQuery ->
  #   $canvas = "<canvas width='500' height='500'></canvas>"
  #   $img = new Image
  #   $img.src = message.image
  #   $('body').append $canvas
  #   $canvas = $('body').find("canvas")
  #   context = $canvas[0].getContext('2d')
  #   $img.onload = ()->
  #     context.drawImage $img, 200, 200, 500, 500, 0, 0, 500, 500

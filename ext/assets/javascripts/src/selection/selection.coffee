class @Selection

  @mouse_x = ($trellosnap, e) ->
    e.pageX - $trellosnap.offset().left

  @mouse_y = ($trellosnap, e) ->
    e.pageY - $trellosnap.offset().top

  @start_drawing_box = (x, y, $trellosnap) ->
    $box = $("#trellosnap-selection-box")
    disable_scroll()
    console.log "#{x},#{y}"
    $box.css
      left : "#{x}px"
      top  : "#{y}px"
    $(document).on "mousemove", (e)  =>
      resize_selection_box x, y, this.mouse_x($trellosnap, e), this.mouse_y($trellosnap, e), $box

  @stop_drawing_box = (x, y, $trellosnap) ->
    console.log "#{x},#{y}"
    $(document).unbind "mousedown"
    $(document).unbind "mouseup"
    $(document).unbind "mousemove"

  @append_selection_box = ->
    $("body").append selection_box_html()

  selection_box_html = ->
    """
      <div id="trellosnap">
        <div class="trellosnap-overlay" id="trellosnap-overlay-top"></div>
        <div class="trellosnap-overlay" id="trellosnap-overlay-right"></div>
        <div class="trellosnap-overlay" id="trellosnap-overlay-bottom"></div>
        <div class="trellosnap-overlay" id="trellosnap-overlay-left"></div>
        <div id="trellosnap-selection-box"></div>
      </div>
    """

  resize_selection_box = (old_x, old_y, new_x, new_y, $box) ->
    $box.css
      width  : "#{if (new_x >= old_x) then (new_x - old_x) else "0"}px"
      height : "#{if (new_y >= old_y) then (new_y - old_y) else "0"}px"

  disable_scroll = ->
    $("html, body").addClass "trellosnap-no-scroll"

jQuery ->

  Selection.append_selection_box() unless $("#trellosnap").length

  $trellosnap = $("#trellosnap")

  $(document).on "mousedown", (e) ->
    e.preventDefault()
    Selection.start_drawing_box Selection.mouse_x($trellosnap, e), Selection.mouse_y($trellosnap, e), $trellosnap
  .on "mouseup", (e) ->
    e.preventDefault()
    Selection.stop_drawing_box Selection.mouse_x($trellosnap, e), Selection.mouse_y($trellosnap, e), $trellosnap
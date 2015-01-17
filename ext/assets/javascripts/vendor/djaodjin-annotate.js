/*
annotate.js
Copyright (c) 2014, Djaodjin Inc.
MIT License
*/

(function($) {
  var _this = null;
  var canvas = null;
  var context = null;
  var clicked = false;
  var fromx = null;
  var fromy = null;
  var fromx_text = null;
  var fromy_text = null;
  var tox = null;
  var toy = null;
  var stored_undo = [];
  var stored_element = [];
  var img = null;

  function Annotate(el, options) {
    this.$el = $(el);
    this.check_redo_undo();
    this.options = options;
    this._init();
  }

  Annotate.prototype = {
    _init: function() {
      _this = this;
      canvas = document.getElementById(_this.$el.attr('id'));

      context = canvas.getContext('2d');
      type = _this.options.type;
      color = _this.options.color;


      $(_this.options.tools_container).append('\
        <div id="annotate_tools" style="display:inline-block">\
          <label class="annotate-undoaction"><button id="undoaction"></button></label>\
          <label class="annotate-rectangle"><input type="radio" name="tool_option" id="rectangle" checked><span></span></label>\
          <!--<label class="annotate-text"><input type="radio" name="tool_option" id="text"><span></span></label>-->\
          <label class="annotate-arrow"><input type="radio" name="tool_option" id="arrow"><span></span></label>\
          <div class="annotate-color-changer">\
            <div class="annotate-color-red active" data-color="red"></div>\
            <div class="annotate-color-blue" data-color="blue"></div>\
            <div class="annotate-color-green" data-color="green"></div>\
            <div class="annotate-color-purple" data-color="purple"></div>\
            <div class="annotate-color-orange" data-color="orange"></div>\
            <div class="annotate-color-yellow" data-color="yellow"></div>\
          </div>\
          <label class="annotate-redoaction"><button id="redoaction"></button></label>\
        </div>\
      ');

      $("body").append('<textarea id="input_text" style="position:absolute;z-index:100000;display:none;top:0;left:0;background:transparent;border:1px dotted ' + _this.options.color + ';font-size:' + _this.options.fontsize + ';font-family:sans-serif;color:' + _this.options.color + ';word-wrap: break-word;outline-width: 0;overflow: hidden;padding:0px;resize: both;line-height:1.3;font-weight: 600;letter-spacing:.5px;"></textarea>');

      $(document).on('change', 'input[name="tool_option"]', _this._selecttool);
      $(document).on('click', '#redoaction', _this.redoaction);
      $(document).on('click', '#undoaction', _this.undoaction);
      _this.$el.on('mousedown', _this._mousedown);
      _this.$el.on('mouseup', _this._mouseup);
      _this.$el.on('mousemove', _this._mousemove);
      _this.check_redo_undo();
    },

    check_redo_undo: function() {
      if (stored_undo.length == 0) {
        $('#redoaction').attr('disabled', true);
      } else {
        $('#redoaction').attr('disabled', false);
      }
      if (stored_element.length == 0) {
        $('#undoaction').attr('disabled', true);
      } else {
        $('#undoaction').attr('disabled', false);
      }
    },

    undoaction: function(event) {
      event.preventDefault();
      stored_undo.push(stored_element[stored_element.length - 1]);
      stored_element.pop();
      _this.check_redo_undo();
      _this.redraw();
    },

    redoaction: function(event) {
      event.preventDefault();
      stored_element.push(stored_undo[stored_undo.length - 1]);
      stored_undo.pop();
      _this.check_redo_undo();
      _this.redraw();
    },

    redraw: function() {
      canvas.width = canvas.width;
      if (stored_element.length == 0) {
        return;
      }
      // redraw each stored line
      for (var i = 0; i < stored_element.length; i++) {
        var element = stored_element[i];
        if (element.type == 'rectangle') {
          _this.drawRectangle(element.fromx, element.fromy, element.tox, element.toy);
        } else if (element.type == 'arrow') {
          _this.drawArrow(element.fromx, element.fromy, element.tox, element.toy);
        } else if (element.type == 'text') {
          _this.drawText(element.text, element.fromx, element.fromy, element.maxwidth);
        }
      }
    },

    drawRectangle: function(x, y, w, h) {
      context.beginPath();
      context.rect(x, y, w, h);
      context.fillStyle = 'transparent';
      context.fill();
      context.lineWidth = _this.options.linewidth;
      context.strokeStyle = _this.options.color;
      context.stroke();
    },

    drawArrow: function(x, y, w, h) {
      var angle = Math.atan2(h - y, w - x);
      context.beginPath();
      context.lineWidth = _this.options.linewidth;
      context.moveTo(x, y);
      context.lineTo(w, h);
      context.lineTo(w - 10 * Math.cos(angle - Math.PI / 6), h - 10 * Math.sin(angle - Math.PI / 6));
      context.moveTo(w, h);
      context.lineTo(w - 10 * Math.cos(angle + Math.PI / 6), h - 10 * Math.sin(angle + Math.PI / 6));
      context.strokeStyle = _this.options.color;
      context.stroke();
    },

    wrapText: function(context, text, x, y, maxWidth, lineHeight) {
      var words = text.split(' ');
      var line = '';

      for (var n = 0; n < words.length; n++) {
        var testLine = line + words[n] + ' ';
        var metrics = context.measureText(testLine);
        var testWidth = metrics.width;
        if (testWidth > maxWidth && n > 0) {
          context.fillText(line, x, y);
          line = words[n] + ' ';
          y += lineHeight;
        } else {
          line = testLine;
        }
      }
      context.fillText(line, x, y);
    },

    drawText: function(text, x, y, maxWidth) {
      context.font = "600 " + _this.options.fontsize + " sans-serif";
      context.textBaseline = 'top';
      context.fillStyle = _this.options.color;
      _this.wrapText(context, text, x + 3, y + 4, maxWidth, 25);
    },

    // Events
    _selecttool: function() {
      _this.options.type = $(this).attr('id');
      if ($('#input_text').is(":visible")) {
        var text = $('#input_text').val();
        $('#input_text').val('').hide();
        if (text != '') {
          stored_element.push({
            'type': 'text',
            'text': text,
            'fromx': fromx,
            'fromy': fromy,
            'maxwidth': tox
          });
          if (stored_undo.length > 0) {
            stored_undo = [];
          }
        }
        _this.redraw();
      }
    },

    _mousedown: function(event) {
      clicked = true;
      var offset = _this.$el.offset();
      if ($('#input_text').is(":visible")) {
        var text = $('#input_text').val();
        $('#input_text').val('').hide();
        if (text != '') {
          if (!tox) {
            tox = 100;
          }
          stored_element.push({
            'type': 'text',
            'text': text,
            'fromx': fromx_text - offset.left,
            'fromy': fromy_text - offset.top,
            'maxwidth': tox
          });
          if (stored_undo.length > 0) {
            stored_undo = [];
          }
        }
        _this.redraw();
      }
      tox = null;
      toy = null;

      fromx = event.pageX - offset.left;
      fromy = event.pageY - offset.top;
      fromx_text = event.pageX;
      fromy_text = event.pageY;
      if (_this.options.type == 'text') {
        $('#input_text').css({
          "left": fromx_text + 2,
          "top": fromy_text,
          "width": 0,
          "height": 0
        }).show();
      }
    },

    _mouseup: function(event) {
      clicked = false;
      if (toy != null && tox != null) {
        if (_this.options.type == 'rectangle') {
          stored_element.push({
            'type': 'rectangle',
            'fromx': fromx,
            'fromy': fromy,
            'tox': tox,
            'toy': toy
          });
        } else if (_this.options.type == 'arrow') {
          stored_element.push({
            'type': 'arrow',
            'fromx': fromx,
            'fromy': fromy,
            'tox': tox,
            'toy': toy
          });
        } else if (_this.options.type == 'text') {
          $('#input_text').css({
            left: fromx_text + 2,
            top: fromy_text,
            width: tox - 12,
            height: toy,
          }).focus();
        }
        if (stored_undo.length > 0) {
          stored_undo = [];
        }
        _this.check_redo_undo();
        _this.redraw();
      } else {
        if (_this.options.type == 'text') {
          $('#input_text').css({
            left: fromx_text + 2,
            top: fromy_text,
            width: "120px",
            height: "90px",
          }).focus();
        }
      }
    },

    _mousemove: function(event) {
      if (clicked == false) return;
      _this.redraw();
      var offset = _this.$el.offset();
      if (_this.options.type == 'rectangle') {
        tox = event.pageX - offset.left - fromx;
        toy = event.pageY - offset.top - fromy;
        _this.drawRectangle(fromx, fromy, tox, toy);
      } else if (_this.options.type == 'arrow') {
        tox = event.pageX - offset.left;
        toy = event.pageY - offset.top;
        _this.drawArrow(fromx, fromy, tox, toy);
      } else if (_this.options.type == 'text') {
        tox = event.pageX - fromx_text;
        toy = event.pageY - fromy_text;
        $('#input_text').css({
          left: fromx_text + 2,
          top: fromy_text,
          width: tox - 12,
          height: toy
        });
      }
    }
  };

  $.fn.annotate = function(options) {
    var opts = $.extend({}, $.fn.annotate.defaults, options);
    annotate = new Annotate($(this), opts);
  };

  $.fn.annotate.defaults = {
    tools_container: "body",
    color: 'red',
    type: 'rectangle',
    linewidth: 3,
    fontsize: '16px',
  };

})(jQuery);

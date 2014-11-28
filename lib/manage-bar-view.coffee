{$, $$, TextEditorView, View} = require 'atom'

module.exports =
  class JekyllManagerView extends View
    @jekyllServer: null

    @content: ->
      @div tabindex: -1, class: 'jekyll-manager-panel', =>

        @div class: 'block', =>
          @span id: 'jekyllVersion', outlet: 'jekyllVersion', 'Jekyll 0.0.0'
          @span id: 'jekyllPWD', outlet: 'jekyllPWD', ' in ...'
          @div class: 'buttons', =>
            @div class: 'btn-group', =>
              @button class: 'btn', outlet: 'toggleButton', 'Loading...'
              @button class: 'btn', 'Open Config'
              @button class: 'btn', click: 'hidePanel', 'Close'

        @div class: 'block', =>
          @div class: 'console', outlet: 'console', id: 'console'

    initialize: (jekyllServer) ->
      JekyllManagerView.jekyllServer = jekyllServer
      JekyllManagerView.jekyllServer.version(@jekyllVersion)
      @jekyllPWD.html('&nbsp;in ' + JekyllManagerView.jekyllServer.pwd)

      @initConsole()
      @initToggleButton()
      @bindEvents()

    setPanel: (panel) ->
      @panel = panel

    hidePanel: ->
      @panel.hide()

    refresh: ->
      @console.html ''
      @initConsole()
      @initToggleButton()

    initConsole: ->
      @console.append 'Server Status: ' + JekyllManagerView.jekyllServer.status() + "<br />"

    initToggleButton: ->
      status = JekyllManagerView.jekyllServer.status()
      if status == 'Off'
        @toggleButton.html('Start Server')

    bindEvents: ->
      @toggleButton.on 'click', ->
        status = JekyllManagerView.jekyllServer.status()
        if status == 'Off'
          JekyllManagerView.jekyllServer.start($('#console'))
          $(this).html('Stop Server')
        else
          JekyllManagerView.jekyllServer.stop()
          $(this).html('Start Server')

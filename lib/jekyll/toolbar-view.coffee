{Emitter} = require 'atom'
{$, View} = require 'space-pen'

module.exports =
  class JekyllManagerView extends View
    @content: ->
      @div tabindex: -1, class: 'jekyll-manager-panel', =>

        @div class: 'block', =>
          @p =>
            @span id: 'jekyllVersion', outlet: 'jekyllVersion', 'Jekyll 0.0.0'
            @span id: 'jekyllPWD', outlet: 'jekyllPWD', ' in ' + atom.project.getPaths()[0]
          @div class: 'buttons', =>
            @div class: 'btn-group', =>
              @button class: 'btn', id: 'toggleButton', outlet: 'toggleButton', click: 'toggleServer', 'Start/Stop Server'
              @button class: 'btn', click: 'hidePanel', 'Close'

    initialize: (@emitter, @main) ->
      @getVersion()

    setPanel: (panel) ->
      @panel = panel

    hidePanel: ->
      @panel.hide()

    refresh: (server) ->

    getVersion: ->
      @emitter.emit 'jekyll:version'
      @emitter.on 'jekyll:version-reply', (data) ->
        $('#jekyllVersion').html(data)

    toggleServer: (event, element) ->
      @main.handleCommand('toggleServer', true, false)

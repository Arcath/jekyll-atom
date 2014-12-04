{$, $$, View} = require 'atom'

module.exports =
  class JekyllStatus extends View
    @content: ->
      @div class:'inline-block', =>
        @span click: 'openToolbar', id: 'jekyllStatusLink', "Jekyll Server"

    initialize: (emitter) ->
      @emitter = emitter

      @emitter.on 'jekyll:server-status-reply', (status) ->
        console.log status
        if status is 'On'
          $('#jekyllStatusLink').addClass('text-success')
        else
          $('#jekyllStatusLink').removeClass('text-success')

      @emitter.emit 'jekyll:server-status'

    openToolbar: ->
      atom.workspaceView.trigger 'jekyll:toolbar'

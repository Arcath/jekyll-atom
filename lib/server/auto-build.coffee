path = require 'path'

Builder = require './build'

module.exports =
  running: false
  disposables: []

  toggle: ->
    if !@running
      @start()
    else
      @stop()


  start: ->
    Builder.build(false)
    @running = true

    @disposables.push atom.workspace.observeTextEditors (editor) => @didOpenFile(editor)

    for editor in atom.workspace.getTextEditors()
      @didOpenFile(editor)

  stop: ->
    @running = false

    for disposable in @disposables
      disposable.dispose()

    atom.notifications.addInfo 'Jekyll Auto Build Stopped.'


  didOpenFile: (editor) ->
    @disposables.push editor.buffer.emitter.on 'did-save', => @didSave()

  didSave: ->
    Builder.build(false)

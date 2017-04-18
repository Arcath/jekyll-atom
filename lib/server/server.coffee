path = require 'path'

Builder = require './build'
StaticServer = require 'static-server'

module.exports =
  server: null
  disposables: []

  toggle: ->
    if @server == null
      @start()
    else
      @stop()


  start: ->
    Builder.build(false)
    @server = new StaticServer({
      rootPath: path.join(atom.project.getPaths()[0], process.jekyllAtom.config.destination),
      name: 'jekyll-atom',
      port: atom.config.get('jekyll.serverPort')
      templates: {
        notFound: path.join(atom.project.getPaths()[0], process.jekyllAtom.config.destination, '404.html')
      }
    })

    @server.start => @serverStarted()

    @disposables.push atom.workspace.observeTextEditors (editor) => @didOpenFile(editor)

  stop: ->
    @server?.stop()
    @server = null
    for disposable in @disposables
      disposable.dispose()

    atom.notifications.addInfo 'Jekyll server stopped'

  serverStarted: ->
    atom.notifications.addSuccess 'Jekyll site available at http://localhost:' + atom.config.get('jekyll.serverPort')

    for editor in atom.workspace.getTextEditors()
      @didOpenFile(editor)

  didOpenFile: (editor) ->
    @disposables.push editor.buffer.emitter.on 'did-save', => @didSave()

  didSave: ->
    Builder.build(true)

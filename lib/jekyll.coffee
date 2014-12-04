{Emitter} = require 'atom'
JekyllEmitter = new Emitter

JekyllNewPostView = require './new-post-view'
JekyllToolbarView = require './toolbar-view'
JekyllManageView = require './manage-view'
JekyllServer = require './server'

module.exports =
  jekyllNewPostView: null

  configDefaults:
    layoutsDir: "_layouts/"
    layoutsType: ".html"
    postsDir: "_posts/"
    postsType: ".markdown"
    includesDir: "_includes/"
    dataDir: "_data/"
    serverOptions: ["serve", "-w"]
    jekyllBinary: "jekyll"

  activate: (state) ->
    atom.workspaceView.command "jekyll:open-layout", => @openLayout()
    atom.workspaceView.command "jekyll:open-config", => @openConfig()
    atom.workspaceView.command "jekyll:open-include", => @openInclude()
    atom.workspaceView.command "jekyll:open-data", => @openData()
    atom.workspaceView.command "jekyll:manage", => @manage()
    atom.workspaceView.command "jekyll:toolbar", => @toolbar()
    atom.workspaceView.command "jekyll:toggle-server", => @toggleServer()

    @jekyllNewPostView = new JekyllNewPostView(state.jekyllNewPostViewState)
    @jekyllServer = new JekyllServer
    @jekyllServer.activate(JekyllEmitter)

    @registerOpenView()

  deactivate: ->
    @jekyllNewPostView.destroy()

  serialize: ->
    jekyllNewPostViewState: @jekyllNewPostView.serialize()
    JekyllEmitter.emit 'jekyll:stop-server'

  showError: (message) ->
    console.log(message)

  openLayout: ->
    activeEditor = atom.workspace.getActiveEditor()
    contents = activeEditor.getText()

    try
      layout = @scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
      atom.workspaceView.open(atom.config.get('jekyll.layoutsDir') + layout + atom.config.get('jekyll.layoutsType'))
    catch error
      @showError(error.message)

  openInclude: ->
    activeEditor = atom.workspace.getActiveEditor()
    line = activeEditor.getCursor().getCurrentBufferLine()

    try
      include = @scan(line, /{% include (.*?)%}/g)[0][0].split(" ")[0]
      atom.workspaceView.open(atom.config.get('jekyll.includesDir') + include)
    catch error
      @showError(error.message)

  openConfig: ->
    atom.workspaceView.open("_config.yml")

  openData: ->
    activeEditor = atom.workspace.getActiveEditor()
    line = activeEditor.getCursor().getCurrentBufferLine()

    try
      data = @scan(line, /site\.data\.(.*?) /g)[0][0].split(" ")[0]
      atom.workspaceView.open(atom.config.get('jekyll.dataDir') + data + ".yml")
    catch error
      @showError(error.message)

  manage: ->
    atom.workspaceView.open('atom://jekyll')

  toolbar: ->
    if @toolbarView
      @toolbarPanel.show()
      @toolbarView.refresh()
    else
      @toolbarView = new JekyllToolbarView(JekyllEmitter)
      @toolbarPanel = atom.workspace.addBottomPanel(item: @toolbarView, visible: true, className: 'tool-panel panel-bottom')
      @toolbarView.setPanel @toolbarPanel

  scan: (string, pattern) ->
    matches = []
    results = []
    while matches = pattern.exec(string)
      matches.shift();
      results.push(matches)

    return results

  registerOpenView: ->
    atom.workspace.registerOpener (uri) ->
      if uri is 'atom://jekyll'
        return new JekyllManageView(JekyllEmitter)

  toggleServer: ->
    JekyllEmitter.emit 'jekyll:toggle-server'

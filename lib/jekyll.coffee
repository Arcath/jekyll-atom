{Emitter} = require 'atom'
JekyllEmitter = new Emitter

JekyllNewPostView = require './new-post-view'
JekyllToolbarView = require './toolbar-view'
JekyllManageView = require './manage-view'
JekyllServer = require './server'
JekyllStatusBar = require './status-bar-view'

module.exports =
  jekyllNewPostView: null

  config:
    layoutsDir:
      type: 'string'
      default: '_layouts/'
    layoutsType:
      type: 'string'
      default: '.html'
    postsDir:
      type: 'string'
      default: '_posts/'
    postsType:
      type: 'string'
      default: '.markdown'
    includesDir:
      type: 'string'
      default: '_includes/'
    dataDir:
      type: 'string'
      default: '_data/'
    jekyllBinary:
      type: 'string'
      default: 'jekyll'
    serverOptions:
      type: 'array'
      default: ['serve', '-w']
      items:
        type: 'string'

  activate: ->
    atom.commands.add 'atom-workspace', "jekyll:open-layout", => @openLayout()
    atom.commands.add 'atom-workspace', "jekyll:open-config", => @openConfig()
    atom.commands.add 'atom-workspace', "jekyll:open-include", => @openInclude()
    atom.commands.add 'atom-workspace', "jekyll:open-data", => @openData()
    atom.commands.add 'atom-workspace', "jekyll:manage", => @manage()
    atom.commands.add 'atom-workspace', "jekyll:toolbar", => @toolbar()
    atom.commands.add 'atom-workspace', "jekyll:toggle-server", => @toggleServer()

    @jekyllNewPostView = new JekyllNewPostView()
    @jekyllServer = new JekyllServer
    @jekyllServer.activate(JekyllEmitter)

    @registerOpenView()

    atom.workspace.statusBar?.appendRight(new JekyllStatusBar(JekyllEmitter))

  deactivate: ->
    @jekyllServer.deactivate()

  serialize: ->
    #jekyllNewPostViewState: @jekyllNewPostView.serialize()
    #JekyllEmitter.emit 'jekyll:stop-server'

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
      atom.workspace.open(atom.config.get('jekyll.dataDir') + data + ".yml")
    catch error
      @showError(error.message)

  manage: ->
    atom.workspace.open('atom://jekyll')

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
    atom.workspace.addOpener (uri) ->
      if uri is 'atom://jekyll'
        return new JekyllManageView(JekyllEmitter)

  toggleServer: ->
    JekyllEmitter.emit 'jekyll:toggle-server'

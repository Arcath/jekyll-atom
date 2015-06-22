fs = require 'fs-plus'

{Emitter} = require 'atom'
JekyllEmitter = new Emitter

JekyllNewPostView = require './new-post-view'
JekyllToolbarView = require './toolbar-view'

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
    draftByDefault:
      type: 'boolean'
      default: false
    draftsDir:
      type: 'string'
      default: '_drafts/'
    jekyllBuildCommand:
      type: 'string'
      default: 'jekyll build'
    expressPort:
      type: 'integer'
      default: 3000

  activate: ->
    atom.commands.add 'atom-workspace', "jekyll:open-layout", => @openLayout()
    atom.commands.add 'atom-workspace', "jekyll:open-config", => @openConfig()
    atom.commands.add 'atom-workspace', "jekyll:open-include", => @openInclude()
    atom.commands.add 'atom-workspace', "jekyll:open-data", => @openData()
    atom.commands.add 'atom-workspace', "jekyll:manage", => @manage()
    atom.commands.add 'atom-workspace', "jekyll:toolbar", => @toolbar()
    atom.commands.add 'atom-workspace', "jekyll:toggle-server", => @toggleServer()
    atom.commands.add 'atom-workspace', 'jekyll:new-post', => @newPost()
    atom.commands.add 'atom-workspace', 'jekyll:build-site', => @buildSite()
    atom.commands.add 'atom-workspace', 'jekyll:publish-draft', => @publishDraft()

    @jekyllNewPostView = new JekyllNewPostView()

    if typeof @toolbarView is 'undefined'
      @toolbarView = new JekyllToolbarView(JekyllEmitter)

    @toolbarPanel = atom.workspace.addBottomPanel(item: @toolbarView, visible: false, className: 'tool-panel panel-bottom')
    @toolbarView.setPanel @toolbarPanel

    @registerOpenView()

    atom.workspace.statusBar?.appendRight(new JekyllStatusBar(JekyllEmitter))

  deactivate: ->

  serialize: ->
    #jekyllNewPostViewState: @jekyllNewPostView.serialize()
    #JekyllEmitter.emit 'jekyll:stop-server'

  showError: (message) ->
    console.log(message)

  openLayout: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    contents = activeEditor.getText()

    try
      layout = @scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
      atom.workspace.open(atom.config.get('jekyll.layoutsDir') + layout + atom.config.get('jekyll.layoutsType'))
    catch error
      @showError(error.message)

  openInclude: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    line = activeEditor.getCursor().getCurrentBufferLine()

    try
      include = @scan(line, /{% include (.*?)%}/g)[0][0].split(" ")[0]
      atom.workspace.open(atom.config.get('jekyll.includesDir') + include)
    catch error
      @showError(error.message)

  openConfig: ->
    atom.workspace.open("_config.yml")

  openData: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    line = activeEditor.getCursor().getCurrentBufferLine()

    try
      data = @scan(line, /site\.data\.(.*?) /g)[0][0].split(" ")[0]
      atom.workspace.open(atom.config.get('jekyll.dataDir') + data + ".yml")
    catch error
      @showError(error.message)

  manage: ->
    atom.workspace.open('atom://jekyll')

  toolbar: ->
    @toolbarPanel.show()
    @toolbarView.refresh()

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

  newPost: ->
    @jekyllNewPostView.attach()
    @jekyllNewPostView.miniEditor.focus()

  buildSite: ->
    JekyllEmitter.emit 'jekyll:build-site'

  publishDraft: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    activeEditor.save()

    currentFilePath = activeEditor?.buffer?.file?.path
    currentFileName = currentFilePath.split("/").reverse()[0]

    newFileName = @generateFileName(@getPostTitle(activeEditor))
    newFilePath = currentFilePath.replace(atom.config.get('jekyll.draftsDir') + currentFileName, atom.config.get('jekyll.postsDir') + newFileName) + atom.config.get('jekyll.postsType')

    contents = activeEditor.getText()
    newContents = contents.replace(/date: "[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}"/, "date: \"#{@generateDateString()}\"")

    fs.writeFileSync(newFilePath, newContents)
    fs.unlinkSync(currentFilePath)

    atom.workspace.open(newFilePath)
    activeEditor.destroy()

  getPostTitle: (editor) ->
    contents = editor.getText()

    title = @scan(contents, /title: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]

  generateFileName: (title) ->
    titleString = title.toLowerCase().replace(/[^\w\s]|_/g, "").replace(RegExp(" ", 'g'),"-")
    return @generateDateString() + '-' + titleString

  generateDateString: (currentTime = new Date()) ->
    return currentTime.getFullYear() + "-" + ("0" + (currentTime.getMonth() + 1)).slice(-2) + "-" + ("0" + currentTime.getDate()).slice(-2)

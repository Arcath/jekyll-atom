fs = require 'fs-plus'
path = require 'path'
yaml = require 'js-yaml'

{Emitter} = require 'atom'
JekyllEmitter = new Emitter

JekyllNewPostView = require './new-post-view'
JekyllToolbarView = require './toolbar-view'

Builder = require './server/build'
Server = require './server/server'

module.exports =
  jekyllNewPostView: null

  config:
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
    draftByDefault:
      type: 'boolean'
      default: false
    draftsDir:
      type: 'string'
      default: '_drafts/'
    serverPort:
      type: 'integer'
      default: 3000
    buildCommand:
      type: 'array'
      default: ['jekyll', 'build']
      items:
        type: 'string'
    siteDir:
      type: 'string'
      default: '_site/'

  activate: ->
    process.jekyllAtom = {}

    atom.commands.add 'atom-workspace', "jekyll:open-layout", => @openLayout()
    atom.commands.add 'atom-workspace', "jekyll:open-config", => @openConfig()
    atom.commands.add 'atom-workspace', "jekyll:open-include", => @openInclude()
    atom.commands.add 'atom-workspace', "jekyll:open-data", => @openData()
    atom.commands.add 'atom-workspace', "jekyll:toolbar", => @toolbar()
    atom.commands.add 'atom-workspace', "jekyll:toggle-server", => @toggleServer()
    atom.commands.add 'atom-workspace', 'jekyll:new-post', => @newPost()
    atom.commands.add 'atom-workspace', 'jekyll:build-site', => @buildSite()
    atom.commands.add 'atom-workspace', 'jekyll:publish-draft', => @publishDraft()

    @jekyllNewPostView = new JekyllNewPostView()
    @getConfigFromSite()

    if typeof @toolbarView is 'undefined'
      @toolbarView = new JekyllToolbarView(JekyllEmitter)

    @toolbarPanel = atom.workspace.addBottomPanel(item: @toolbarView, visible: false, className: 'tool-panel panel-bottom')
    @toolbarView.setPanel @toolbarPanel

  deactivate: ->
    Server.stop()

  serialize: ->
    Server.stop()

  showError: (message) ->
    console.log(message)

  getConfigFromSite: ->
    fs.open(path.join(atom.project.getPaths()[0], '_config.yml'), 'r', (err, fd) => @handleConfigFileOpen(err, fd))

  handleConfigFileOpen: (err, fd) ->
    unless err
      process.jekyllAtom.config = yaml.safeLoad(fs.readFileSync(path.join(atom.project.getPaths()[0], '_config.yml')))
      process.jekyllAtom.config.layouts_dir = './_layouts' unless process.jekyllAtom.config.layouts_dir

  openLayout: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    if activeEditor
      contents = activeEditor.getText()
    else
      atom.notifications.addWarning('Could not see Active Editor, do you have an editor open?')

    try
      layout = @scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
      fs.readdir process.jekyllAtom.config.layouts_dir, (err, files) ->
        for file in files
          parts = file.split(".")
          if parts[0] == layout
            fileName = file

        atom.workspace.open(path.join(process.jekyllAtom.config.layouts_dir, fileName))
    catch error
      if error.message == "Cannot read property 'layouts_dir' of undefined"
        # Just in case we havent read the config yet.
        setTimeout(->
          atom.packages.getActivePackage('jekyll').mainModule.openLayout()
        ,500 )

      else
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
    @toolbarView.refresh(Server)

  scan: (string, pattern) ->
    matches = []
    results = []
    while matches = pattern.exec(string)
      matches.shift();
      results.push(matches)

    return results

  toggleServer: ->
    Server.toggle()

  newPost: ->
    @jekyllNewPostView.attach()
    @jekyllNewPostView.miniEditor.focus()

  buildSite: ->
    Builder.build()

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

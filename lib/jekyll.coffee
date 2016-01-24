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
  disposables: []

  config:
    postsDir:
      type: 'string'
      default: '_posts/'
    postsType:
      type: 'string'
      default: '.markdown'
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

  activate: ->
    process.jekyllAtom = {
      buildCommand: atom.config.get('jekyll.buildCommand')
    }

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

    JekyllEmitter.on 'config-loaded', => @dispose

    if typeof @toolbarView is 'undefined'
      @toolbarView = new JekyllToolbarView(JekyllEmitter)

    @toolbarPanel = atom.workspace.addBottomPanel(item: @toolbarView, visible: false, className: 'tool-panel panel-bottom')
    @toolbarView.setPanel @toolbarPanel

  dispose: ->
    for disposeable in @disposables
      disposeable.dispose()

  deactivate: ->
      Server.stop()

  showError: (message) ->
    console.log(message)

  getConfigFromSite: ->
    fs.open(path.join(atom.project.getPaths()[0], '_config.yml'), 'r', (err, fd) => @handleConfigFileOpen(err, fd))

  handleConfigFileOpen: (err, fd) ->
    unless err
      process.jekyllAtom.config = yaml.safeLoad(fs.readFileSync(path.join(atom.project.getPaths()[0], '_config.yml')))
      process.jekyllAtom.config.layouts_dir = './_layouts' unless process.jekyllAtom.config.layouts_dir
      process.jekyllAtom.config.includes_dir = './_includes' unless process.jekyllAtom.config.includes_dir
      process.jekyllAtom.config.data_dir = './_data' unless process.jekyllAtom.config.data_dir

      JekyllEmitter.emit 'config-loaded', process.jekyllAtom.config

  ifConfigLoaded: (cb) ->
    if process.jekyllAtom.config
      cb(process.jekyllAtom.config)
    else
      @disposables.push JekyllEmitter.on 'config-loaded', (conf) => cb(conf)

  openLayout: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    if activeEditor
      contents = activeEditor.getText()
    else
      atom.notifications.addWarning('Could not see Active Editor, do you have an editor open?')
    try
      @ifConfigLoaded (conf) ->
        layout = module.exports.scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
        fs.readdir path.join(atom.project.getPaths()[0], conf.layouts_dir), (err, files) ->
          for file in files
            parts = file.split(".")
            if parts[0] == layout
              fileName = file

          atom.workspace.open(path.join(process.jekyllAtom.config.layouts_dir, fileName))
    catch error
      @showError(error.message)

  openInclude: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    buffer = activeEditor.getBuffer()
    line = buffer.lines[activeEditor.getCursorBufferPosition().row]

    try
      @ifConfigLoaded (conf) ->
        include = module.exports.scan(line, /{% include (.*?)%}/g)[0][0].split(" ")[0]
        atom.workspace.open(path.join(process.jekyllAtom.config.includes_dir, include))
    catch error
      @showError(error.message)

  openConfig: ->
    atom.workspace.open("_config.yml")

  openData: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    buffer = activeEditor.getBuffer()
    line = buffer.lines[activeEditor.getCursorBufferPosition().row]

    try
      @ifConfigLoaded (conf) ->
        data = module.exports.scan(line, /site\.data\.(.*?) /g)[0][0].split(" ")[0]
        atom.workspace.open(path.join(conf.data_dir, data) + ".yml")
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
    @ifConfigLoaded (conf) ->
      Server.toggle()

  newPost: ->
    @jekyllNewPostView.attach()
    @jekyllNewPostView.miniEditor.focus()

  buildSite: ->
    @ifConfigLoaded (conf) ->
      console.dir conf
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

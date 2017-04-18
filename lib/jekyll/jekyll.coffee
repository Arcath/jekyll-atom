fs = require 'fs-plus'
path = require 'path'

Utils = require './utils'

JekyllNewPostView = require './new-post-view'

AutoBuild = require '../server/auto-build'
Builder = require '../server/build'
Server = require '../server/server'

module.exports =
  jekyllNewPostView: null

  createNewPostView: ->
    @jekyllNewPostView = new JekyllNewPostView()

  showError: (message) ->
    console.log(message)

  openLayout: (conf) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    contents = activeEditor.getText()

    try
      layout = Utils.scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
      fs.readdir path.join(atom.project.getPaths()[0], conf.layouts_dir), (err, files) ->
        for file in files
          parts = file.split(".")
          if parts[0] == layout
            fileName = file

        atom.workspace.open(path.join(conf.layouts_dir, fileName))
    catch error
      @showError(error.message)

  openInclude: (config) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    buffer = activeEditor.getBuffer()
    line = buffer.lines[activeEditor.getCursorBufferPosition().row]

    try
      include = Utils.scan(line, /{% include (.*?)%}/g)[0][0].split(" ")[0]
      atom.workspace.open(path.join(config.includes_dir, include))
    catch error
      @showError(error.message)

  openConfig: ->
    atom.workspace.open("_config.yml")

  openData: (config) ->
    activeEditor = atom.workspace.getActiveTextEditor()
    buffer = activeEditor.getBuffer()
    line = buffer.lines[activeEditor.getCursorBufferPosition().row]

    try
      data = Utils.scan(line, /site\.data\.(.*?) /g)[0][0].split(" ")[0]
      atom.workspace.open(path.join(config.data_dir, data) + ".yml")
    catch error
      @showError(error.message)

  toggleServer: ->
    Server.toggle()

  toggleAutoBuild: ->
    AutoBuild.toggle()

  newPost: (config) ->
    @createNewPostView() unless @jekyllNewPostView

    @jekyllNewPostView.attach()
    @jekyllNewPostView.refs.input.element.focus()

  buildSite: (config) ->
    Builder.build()

  publishDraft: ->
    activeEditor = atom.workspace.getActiveTextEditor()
    activeEditor.save()

    currentFilePath = activeEditor?.buffer?.file?.path
    currentFileName = currentFilePath.split(path.sep).reverse()[0]

    newFileName = Utils.generateFileName(Utils.getPostTitle(activeEditor))
    newFilePath = path.join(atom.project.getPaths()[0], '_posts', newFileName + '.markdown')

    contents = activeEditor.getText()
    newContents = contents.replace(/date: "[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}.*?"/, "date: \"#{Utils.generateDateString(new Date, true)}\"")

    fs.writeFileSync(newFilePath, newContents)
    fs.unlinkSync(currentFilePath)

    atom.workspace.open(newFilePath)
    activeEditor.destroy()

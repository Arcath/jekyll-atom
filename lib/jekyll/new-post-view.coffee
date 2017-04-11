{TextEditor} = require 'atom'
etch = require('etch')
path = require 'path'
fs = require 'fs-plus'
os = require 'os'
Utils = require('./utils')

module.exports =
  class JekyllNewPostView
    constructor: (props, children) ->
      etch.initialize(@)

      atom.commands.add @element,
        'core:confirm': => @onConfirm()
        'core:cancel': => @destroy()

    render: ->
      etch.dom.div {id: 'jekyll-new-post-view'},
        etch.dom.label {}, "Post Title"
        etch.dom TextEditor, {ref: 'input', mini: true}

        if process.jekyllAtom.config.atom?.postDirs
          for dir in process.jekyllAtom.config.atom.postDirs
            etch.dom.label {className: 'input-label'},
              etch.dom.input {type: 'radio', ref: 'dir[' + dir + ']', className: 'input-radio', name: 'dir', checked: (process.jekyllAtom.config.atom.defaultPostDir == dir)}
              dir

    update: (props, children) ->
      return etch.update(@)

    destroy: ->
      @panel.destroy()
      @refs.input.setText ""
      atom.workspace.getActivePane().activate()

    attach: ->
      @panel = atom.workspace.addModalPanel(item: this)

    onConfirm: ->
      postDir = process.jekyllAtom.config.atom.defaultPostDir
      if process.jekyllAtom.config.atom?.postDirs
        for dir in process.jekyllAtom.config.atom.postDirs
          if @refs['dir[' + dir + ']'].checked
            postDir = dir

      title = @refs.input.getText()
      fileName = Utils.generateFileName title
      relativePath = path.join(process.jekyllAtom.config.source, postDir, fileName + process.jekyllAtom.config.postFileType)
      endsWithDirectorySeparator = /\/$/.test(relativePath)
      pathToCreate = atom.project.getDirectories()[0]?.resolve(relativePath)
      return unless pathToCreate

      try
        if fs.existsSync(pathToCreate)
          atom.notifications.addError("'#{pathToCreate}' already exists.")
          @destroy()
        else
          if endsWithDirectorySeparator
            atom.notifications.addError("File names must not end with a '/' character.")
            @destroy()
          else
            fs.writeFileSync(pathToCreate, @fileContents(title, Utils.generateDateString(new Date(), true)))
            atom.workspace.open(pathToCreate)
            @destroy()
      catch error
        atom.notifications.addError("#{error.message}.")

    fileContents: (title, dateString) ->
      [
        '---'
        'layout: post'
        "title: \"#{title}\""
        "date: \"#{dateString}\""
        '---'
      ].join(os.EOL)

{TextEditorView} = require 'atom-space-pen-views'
path = require 'path'
fs = require 'fs-plus'
os = require 'os'

{$, View} = require 'space-pen'

Utils = require './utils'

module.exports =
class JekyllNewPostView extends View
  @content: ->
    @div class: 'jekyll-new-post overlay from-top', =>
      @label "Post Title", class: 'icon icon-file-add', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)

      if process.jekyllAtom.config.atom?.postDirs
        for dir in process.jekyllAtom.config.atom.postDirs
          @label dir
          @input type: 'checkbox', outlet: 'dirCheckbox'+ dir, 'data-dir': dir


      @button outlet: 'createButton', 'Create'
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ->
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @destroy()

    @createButton.on 'click', => @onConfirm(@miniEditor.getText())

  attach: ->
    if process.jekyllAtom.config.atom?.postDirs
      for dir in process.jekyllAtom.config.atom.postDirs
        _ = @

        @['dirCheckbox' + dir].on 'change', ->
          if $(this).prop 'checked'
              console.dir ['dirCheckbox' + sdir, _['dirCheckbox' + sdir].prop('data-dir'), dir]
              if sdir != dir
                _['dirCheckbox' + sdir].prop('checked', false)


        if dir == process.jekyllAtom.config.atom.defaultPostDir
          @['dirCheckbox' + dir].prop('checked', true)
        else
          @['dirCheckbox' + dir].prop('checked', false)

    @panel = atom.workspace.addModalPanel(item: this)

  destroy: ->
    @panel.destroy()
    atom.workspace.getActivePane().activate()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
      @miniEditor.focus()

  showError: (error)->
    @errorMessage.text(error)
    @flashError() if error

  onConfirm: (title) ->
    postDir = '_posts'
    if process.jekyllAtom.config.atom?.postDirs
      for dir in process.jekyllAtom.config.atom.postDirs
        if !!@['dirCheckbox' + dir].prop('checked')
          postDir = dir


    fileName = Utils.generateFileName title
    relativePath = path.join(process.jekyllAtom.config.source, postDir, fileName + '.markdown')
    endsWithDirectorySeparator = /\/$/.test(relativePath)
    pathToCreate = atom.project.getDirectories()[0]?.resolve(relativePath)
    return unless pathToCreate

    try
      if fs.existsSync(pathToCreate)
        @showError("'#{pathToCreate}' already exists.")
      else
        if endsWithDirectorySeparator
          @showError("File names must not end with a '/' character.")
        else
          fs.writeFileSync(pathToCreate, @fileContents(title, Utils.generateDateString(new Date(), true)))
          atom.workspace.open(pathToCreate)
          @destroy()
    catch error
      @showError("#{error.message}.")

  fileContents: (title, dateString) ->
    [
      '---'
      'layout: post'
      "title: \"#{title}\""
      "date: \"#{dateString}\""
      '---'
    ].join(os.EOL)

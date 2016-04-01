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
      @label "Draft"
      @input type: 'checkbox', outlet: 'draftCheckbox'

      if process.jekyllAtom.config.atom?.postDirs
        for dir in process.jekyllAtom.config.atom.postDirs
          @label dir
          @input type: 'checkbox', outlet: 'dirCheckbox'+ dir


      @button outlet: 'createButton', 'Create'
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ->
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @destroy()

    @createButton.on 'click', => @onConfirm(@miniEditor.getText())

  attach: ->
    if atom.config.get('jekyll.draftByDefault')
      @draftCheckbox.prop('checked', true)

    if process.jekyllAtom.config.atom?.postDirs
      for dir in process.jekyllAtom.config.atom.postDirs
        if dir == process.jekyllAtom.config.atom.postDirs[0]
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
    draft = !!@draftCheckbox.prop('checked')

    postDir = '_posts'
    if process.jekyllAtom.config.atom?.postDirs
      for dir in process.jekyllAtom.config.atom.postDirs
        if !!@['dirCheckbox' + dir].prop('checked')
          postDir = dir


    fileName = Utils.generateFileName(title, draft)
    if draft
      relativePath = path.join(process.jekyllAtom.config.source, '_drafts', fileName + '.markdown')
    else
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

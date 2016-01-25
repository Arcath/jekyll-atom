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
      @button outlet: 'createButton', 'Create'
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ->
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @destroy()

    @createButton.on 'click', => @onConfirm(@miniEditor.getText())

  attach: ->
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
    fileName = Utils.generateFileName(title, draft)
    if draft
      relativePath = path.join('_drafts', fileName + '.markdown')
    else
      relativePath = path.join('_posts', fileName + '.markdown')
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

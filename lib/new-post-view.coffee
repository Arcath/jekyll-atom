{TextEditorView} = require 'atom-space-pen-views'
path = require 'path'
fs = require 'fs-plus'
os = require 'os'

{$, View} = require 'space-pen'

module.exports =
class JekyllNewPostView extends View
  @content: ->
    @div class: 'jekyll-new-post overlay from-top', =>
      @label "Post Title", class: 'icon icon-file-add', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ->
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @destroy()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

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

  generateFileName: (title) ->
    titleName = title.toLowerCase().replace(/[^\w\s]|_/g, "").replace(RegExp(" ", 'g'),"-")
    return @generateDateString() + "-" + titleName

  generateDateString: (currentTime = new Date())->
    return currentTime.getFullYear() + "-" + ("0" + (currentTime.getMonth() + 1)).slice(-2) + "-" + ("0" + currentTime.getDate()).slice(-2)

  onConfirm: (title) ->
    fileName = @generateFileName(title)
    dateString = @generateDateString()
    relativePath = atom.config.get('jekyll.postsDir') + fileName + atom.config.get('jekyll.postsType')
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
          fs.writeFileSync(pathToCreate, @fileContents(title, dateString))
          #atom.project.getRepo()?.getPathStatus(pathToCreate)
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

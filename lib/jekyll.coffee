JekyllNewPostView = require './new-post-view'
childProcess = require 'child_process'

module.exports =
  jekyllNewPostView: null

  configDefaults:
    layoutsDir: "_layouts/"
    layoutsType: ".html"
    postsDir: "_posts/"
    postsType: ".markdown"
    includesDir: "_includes/"

  activate: (state) ->
    atom.workspaceView.command "jekyll:open-layout", => @openLayout()
    atom.workspaceView.command "jekyll:open-config", => @openConfig()
    atom.workspaceView.command "jekyll:open-include", => @openInclude()
    @jekyllNewPostView = new JekyllNewPostView(state.jekyllNewPostViewState)

  deactivate: ->
    @jekyllNewPostView.destroy()

  serialize: ->
    jekyllNewPostViewState: @jekyllNewPostView.serialize()

  showError: (message) ->
    console.log(message)

  openLayout: ->
    activeEditor = atom.workspace.getActiveEditor()
    contents = activeEditor.getText()

    try
      layout = @scan(contents, /layout: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]
      atom.workspaceView.open("_layouts/" + layout + ".html")
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

  scan: (string, pattern) ->
    matches = []
    results = []
    while matches = pattern.exec(string)
      matches.shift();
      results.push(matches)

    return results

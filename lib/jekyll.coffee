JekyllNewPostView = require './new-post-view'
JekyllManageView = require './manage-view'

createManageView = (params) ->
  manageView = new JekyllManageView(params)

module.exports =
  jekyllNewPostView: null

  configDefaults:
    layoutsDir: "_layouts/"
    layoutsType: ".html"
    postsDir: "_posts/"
    postsType: ".markdown"
    includesDir: "_includes/"
    dataDir: "_data/"
    serverOptions: ["serve", "-w"]

  activate: (state) ->
    atom.workspaceView.command "jekyll:open-layout", => @openLayout()
    atom.workspaceView.command "jekyll:open-config", => @openConfig()
    atom.workspaceView.command "jekyll:open-include", => @openInclude()
    atom.workspaceView.command "jekyll:open-data", => @openData()
    atom.workspaceView.command "jekyll:manage", => @manage()

    atom.workspace.registerOpener (uri) ->
      createManageView({uri}) if uri is 'atom://jekyll'

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
      atom.workspaceView.open(atom.config.get('jekyll.layoutsDir') + layout + atom.config.get('jekyll.layoutsType'))
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

  openData: ->
    activeEditor = atom.workspace.getActiveEditor()
    line = activeEditor.getCursor().getCurrentBufferLine()

    try
      data = @scan(line, /site\.data\.(.*?) /g)[0][0].split(" ")[0]
      atom.workspaceView.open(atom.config.get('jekyll.dataDir') + data + ".yml")
    catch error
      @showError(error.message)

  manage: ->
    atom.workspaceView.open('atom://jekyll')

  scan: (string, pattern) ->
    matches = []
    results = []
    while matches = pattern.exec(string)
      matches.shift();
      results.push(matches)

    return results

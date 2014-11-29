{$, $$, ScrollView} = require 'atom'
childProcess = require 'child_process'
jekyllServer = null

module.exports =
class ManagerView extends ScrollView
  @server: null

  @content: ->
    @div class: "jekyll-manager-view pane-item", tabindex: -1, =>
      @div class: "controls", =>
        @div class: "jekyll-logo"
        @a class: "button icon icon-tools", outlet: "openConfig", "Open Config"
        @a class: "button icon icon-repo", outlet: "openDocs", "View Documentation"
        @div class: "heading icon icon-server", "Server"
        @a class: "button icon icon-playback-play", outlet: "startServer", "Start Server"
        @a class: "button icon icon-primitive-square", outlet: "stopServer", "Stop Server"
        @div class: "heading icon icon-device-desktop", "Site"
        @a class: "button icon icon-sync", outlet: "regenSite", "Build"
      @div class: 'main', =>
        @div class: 'jekyll-status-bar', outlet: "statusBar", =>
          @div class: 'jekyll-version', outlet: "jekyllVersion"
          @div class: 'pwd', outlet: "jekyllPWD"
          @div class: 'server-status', outlet: "serverStatus", "Server Status: ", =>
            @span class: 'highlight-error', "Off"
        @pre class: 'console', outlet: "console"

  getTitle: ->
    'Jekyll Manager'

  getIconName: ->
    'settings'

  initialize: ->
    super

    @getInfo()
    @bindEvents()

  getInfo: ->
    @jekyllPWD.html atom.project.getPath()

    versionCommand = atom.config.get('jekyll.jekyllBinary') + " -v"

    childProcess.exec versionCommand, (error, stdout, stderr) ->
      $('.jekyll-version').html(stdout.replace(/j/,"J"))

  bindEvents: ->
    @openConfig.on 'click', ->
      atom.workspaceView.open("_config.yml")

    @startServer.on 'click', ->
      $('.server-status span').html("Running")
      $('.server-status span').addClass("highlight-success")
      $('.server-status span').removeClass("highlight-error")

      $('.console').append("Launching Server... <i>(" + atom.config.get('jekyll.jekyllBinary') + " " + atom.config.get('jekyll.serverOptions').join(" ") + ")</i><br />")


      ManagerView.server = childProcess.spawn atom.config.get('jekyll.jekyllBinary'), atom.config.get('jekyll.serverOptions'), {cwd: atom.project.getPath()}
      ManagerView.server.stdout.setEncoding('utf8')

      ManagerView.bindServerEvents()

    @stopServer.on 'click', ->
      $('.server-status span').html("Off")
      $('.server-status span').addClass("highlight-error")
      $('.server-status span').removeClass("highlight-success")

      killCMD = "kill " + ManagerView.server.pid
      $('.console').append("Stopping Server... <i>(" + killCMD + ")</i><br />")
      $('.console').animate({"scrollTop": $('.console')[0].scrollHeight}, "fast")

      childProcess.exec killCMD

    @regenSite.on 'click', ->
      $('.console').append("Building Website...")
      childProcess.exec "jekyll build"
      $('.console').append("Done!<br />")

    @openDocs.on 'click', ->
      require('shell').openExternal('http://jekyllrb.com/docs/home/')
      false

  @bindServerEvents: ->

    @server.stdout.on 'data', (data) ->
      with_brs = data.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
      with_changes = with_brs.replace(/ctrl-c/, "<i>Stop Server</i>")
      $('.console').append(with_changes)
      $('.console').animate({"scrollTop": $('.console')[0].scrollHeight}, "fast")

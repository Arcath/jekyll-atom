{$, $$, ScrollView} = require 'atom'
childProcess = require 'child_process'
jekyllServer = null

module.exports =
class ManagerView extends ScrollView
  @server: null
  @stdout: null

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
            @span class: 'off', "Off"
        @div class: 'console', outlet: "console", "Start the server using the controls on the left"

  getTitle: ->
    'Jekyll Manager'

  getIconName: ->
    'settings'

  initialize: ->
    super

    ManagerView.stdout = @console

    @getInfo()
    @bindEvents()

  getInfo: ->
    @jekyllPWD.html atom.project.getPath()

    childProcess.exec "jekyll -v", (error, stdout, stderr) ->
      $('.jekyll-version').html(stdout.replace(/j/,"J"))

  bindEvents: ->
    @openConfig.on 'click', ->
      atom.workspaceView.open("_config.yml")

    @startServer.on 'click', ->
      $('.server-status span').html("Running")
      $('.server-status span').addClass("on")
      $('.server-status span').removeClass("off")

      $('.console').html("Launching Server... <i>(jekyll serve -w)</i><br />")


      ManagerView.server = childProcess.spawn "jekyll", ["serve", "-w"], {cwd: atom.project.getPath()}
      ManagerView.server.stdout.setEncoding('utf8')

      ManagerView.bindServerEvents()

    @stopServer.on 'click', ->
      $('.server-status span').html("Off")
      $('.server-status span').addClass("off")
      $('.server-status span').removeClass("on")

      killCMD = "kill " + ManagerView.server.pid
      $('.console').append("Stopping Server... <i>(" + killCMD + ")</i><br />")

      childProcess.exec killCMD

    @regenSite.on 'click', ->
      $('.console').append("Building Website...")
      childProcess.exec "jekyll build"
      $('.console').append("Done!<br />")

  @bindServerEvents: ->

    @server.stdout.on 'data', (data) ->
      with_brs = data.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
      with_changes = with_brs.replace(/ctrl-c/, "<i>Stop Server</i>")
      $('.console').append(with_changes)

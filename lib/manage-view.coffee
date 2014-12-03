{$, $$, ScrollView} = require 'atom'

module.exports =
class ManagerView extends ScrollView
  @content: ->
    @div class: "jekyll-manager-view pane-item", tabindex: -1, =>
      @div class: "controls", =>
        @div class: "jekyll-logo"
        @a class: "button icon icon-tools", outlet: "openConfig", "Open Config"
        @a class: "button icon icon-repo", outlet: "openDocs", "View Documentation"
        @div class: "heading icon icon-server", "Server"
        @a class: "button icon icon-playback-play", outlet: "startServer", click: 'startServer', "Start Server"
        @a class: "button icon icon-primitive-square", outlet: "stopServer", click: 'stopServer', "Stop Server"
        @div class: "heading icon icon-device-desktop", "Site"
        @a class: "button icon icon-sync", outlet: "regenSite", click: 'buildSite', "Build"
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

  initialize: (emitter) ->
    super
    @emitter = emitter

    @getInfo()
    @bindEvents()
    @bindEmitters()

  getInfo: ->
    @jekyllPWD.html atom.project.getPath()

  afterAttach: ->
    @emitter.emit 'jekyll:pre-fill-console'
    @emitter.emit 'jekyll:server-status'
    @emitter.emit 'jekyll:version'

  beforeRemove: ->
    @versionEmitter.dispose()
    @statusEmitter.dispose()
    @consoleFillEmitter.dispose()
    @consoleMessageEmitter.dispose()


  bindEvents: ->
    @openConfig.on 'click', ->
      atom.workspaceView.open("_config.yml")

    @openDocs.on 'click', ->
      require('shell').openExternal('http://jekyllrb.com/docs/home/')
      false

  bindEmitters: ->
    @versionEmitter = @emitter.on 'jekyll:version-reply', (data) ->
      $('.jekyll-version').html(data)

    @statusEmitter = @emitter.on 'jekyll:server-status-reply', (status) ->
      if status == 'Off'
        $('.server-status span').html("Off")
        $('.server-status span').addClass("highlight-error")
        $('.server-status span').removeClass("highlight-success")
      else
        $('.server-status span').html("Running")
        $('.server-status span').addClass("highlight-success")
        $('.server-status span').removeClass("highlight-error")

    @consoleFillEmitter = @emitter.on 'jekyll:console-fill', (data) ->
      $('.console').html(data)
      $('.console').animate({"scrollTop": $('.console')[0].scrollHeight}, "fast")

    @consoleMessageEmitter = @emitter.on 'jekyll:console-message', (message) ->
      $('.console').append(message)
      $('.console').animate({"scrollTop": $('.console')[0].scrollHeight}, "fast")

  startServer: (event, element) ->
    @emitter.emit 'jekyll:start-server'
    false

  stopServer: (event, element) ->
    @emitter.emit 'jekyll:stop-server'
    false

  buildSite: (event, element) ->
    @emitter.emit 'jekyll:build-site'
    false

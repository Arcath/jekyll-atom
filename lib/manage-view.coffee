{ScrollView} = require 'atom-space-pen-views'
{$} = require 'space-pen'

module.exports =
class ManagerView extends ScrollView
  @content: ->
    @div class: 'jekyll-manager', =>
      @div class: 'controls', =>
        @div class: 'left-buttons btn-group', =>
          @button class: 'btn btn-primary icon icon-tools', outlet: 'openConfig', "Open Config"
          @button class: "btn btn-primary button icon icon-repo", outlet: "openDocs", "View Documentation"
        @div class: 'right-buttons btn-group', =>
          @button class: "btn btn-primary button icon icon-playback-play", click: 'startServer', "Start Server"
          @button class: "btn btn-primary button icon icon-primitive-square", click: 'stopServer', "Stop Server"
          @button class: "btn btn-primary button icon icon-sync", outlet: "regenSite", click: 'buildSite', "Build"
      @pre class: 'console', outlet: 'console'
      @div class: 'info', =>
        @div class: 'left-info', =>
          @span class: 'jekyll-version', outlet: "jekyllVersion"
          @span ' in '
          @span class: 'pwd', outlet: "jekyllPWD"
        @div class: 'right-info', =>
          @div class: 'server-status', outlet: "serverStatus", =>
            @span class: 'highlight-error', "Server Off"


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
    @jekyllPWD.html atom.project.getPaths()[0]

  attached: ->
    @emitter.emit 'jekyll:pre-fill-console'
    @emitter.emit 'jekyll:server-status'
    @emitter.emit 'jekyll:version'

  detached: ->
    @versionEmitter.dispose()
    @statusEmitter.dispose()
    @consoleFillEmitter.dispose()
    @consoleMessageEmitter.dispose()


  bindEvents: ->
    @openConfig.on 'click', ->
      atom.workspace.open("_config.yml")

    @openDocs.on 'click', ->
      require('shell').openExternal('http://jekyllrb.com/docs/home/')
      false

  bindEmitters: ->
    @versionEmitter = @emitter.on 'jekyll:version-reply', (data) ->
      $('.jekyll-version').html(data)

    @statusEmitter = @emitter.on 'jekyll:server-status-reply', (status) ->
      if status == 'Off'
        $('.server-status span').html("Server Off")
        $('.server-status span').addClass("highlight-error")
        $('.server-status span').removeClass("highlight-success")
      else
        $('.server-status span').html("Server Running")
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

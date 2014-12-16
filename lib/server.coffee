childProcess = require 'child_process'

module.exports =
  class JekyllServer
    pwd: atom.project.getPaths()[0]
    process: null
    consoleLog: ''
    emitter: null

    activate: (emitter) ->
      @emitter = emitter
      JekyllServer.emitter = @emitter

      @emitter.on 'jekyll:start-server', => @start()
      @emitter.on 'jekyll:stop-server', => @stop()
      @emitter.on 'jekyll:server-status', => @status()
      @emitter.on 'jekyll:version', => @version()
      @emitter.on 'jekyll:pre-fill-console', => @preFillConsole()
      @emitter.on 'jekyll:build-site', => @buildSite()
      @emitter.on 'jekyll:toggle-server', => @toggle()

    pid: ->
      if @process is null
        return 0
      else
        return @process.pid

    status: ->
      @emitter.emit 'jekyll:server-status-reply', @rawStatus()

    rawStatus: ->
      if @pid() == 0
        return 'Off'
      else
        return 'On'

    version: ->
      versionCommand = atom.config.get('jekyll.jekyllBinary') + " -v"

      childProcess.exec versionCommand, (error, stdout, stderr) ->
        JekyllServer.emitter.emit 'jekyll:version-reply', stdout.replace('j','J')

    start: ->
      launchMSG = "Launching Server... <i>(" + atom.config.get('jekyll.jekyllBinary') + " " + atom.config.get('jekyll.serverOptions').join(" ") + ")</i><br />"
      @emitMessage launchMSG

      @process = childProcess.spawn atom.config.get('jekyll.jekyllBinary'), atom.config.get('jekyll.serverOptions'), {cwd: @pwd}
      @process.stdout.setEncoding('utf8')
      @emitter.emit 'jekyll:log-pid', @process.pid

      @status()

      @process.stdout.on 'data', (data) ->
        with_brs = data.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2')
        with_changes = with_brs.replace(/ctrl-c/, "<i>Stop Server</i>")
        with_colors = with_changes.replace(/done/, "<span class=\"text-success\">done</span>").replace(/error/, "<span class=\"text-error\">error</span>")
        JekyllServer.consoleLog += with_colors
        JekyllServer.emitter.emit 'jekyll:console-message', with_colors

      @process.stderr.on 'data', (data) ->
        with_brs = data.toString().replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2')
        JekyllServer.consoleLog += with_brs
        JekyllServer.emitter.emit 'jekyll:console-message', with_brs

    stop: ->
      @emitMessage "Stopping Server<br />"
      @process.kill('SIGTERM')

      @process = null
      @status()

    deactivate: ->
      if @process
        @process.kill("SIGTERM")
        @process = null

    preFillConsole: ->
      @emitter.emit 'jekyll:console-fill', JekyllServer.consoleLog

    emitMessage: (message) ->
      JekyllServer.consoleLog += message
      @emitter.emit('jekyll:console-message', message)

    buildSite: ->
      @emitMessage 'Building Site...<br />'

      buildCommand = atom.config.get('jekyll.jekyllBinary') + " build"

      childProcess.exec buildCommand, (error, stdout, stderr) ->
        JekyllServer.emitter.emit 'jekyll:console-message', stdout

    toggle: ->
      if @pid() is 0
        @start()
        atom.notifications.addSuccess('Jekyll Server Started')
      else
        @stop()
        atom.notifications.addSuccess('Jekyll Server Stopped')

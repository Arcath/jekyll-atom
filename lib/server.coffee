childProcess = require 'child_process'

module.exports =
  class JekyllServer
    pwd: atom.project.getPath()
    pid: 0
    process: null
    consoleElement: null

    status: ->
      if @pid == 0
        return 'Off'
      else
        return 'On'

    version: (el) ->
      versionCommand = atom.config.get('jekyll.jekyllBinary') + " -v"

      childProcess.exec versionCommand, (error, stdout, stderr) ->
        el.html stdout.replace(/j/,"J")

    start: (consoleElement) ->
      JekyllServer.consoleElement = consoleElement
      JekyllServer.consoleElement.html("Launching Server... <i>(" + atom.config.get('jekyll.jekyllBinary') + " " + atom.config.get('jekyll.serverOptions').join(" ") + ")</i><br />")

      @process = childProcess.spawn atom.config.get('jekyll.jekyllBinary'), atom.config.get('jekyll.serverOptions'), {cwd: @pwd}
      @process.stdout.setEncoding('utf8')

      @pid = @process.pid

      @process.stdout.on 'data', (data) ->
        with_brs = data.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
        with_changes = with_brs.replace(/ctrl-c/, "<i>Stop Server</i>")
        JekyllServer.consoleElement.append(with_changes)
        JekyllServer.consoleElement.animate({"scrollTop": JekyllServer.consoleElement[0].scrollHeight}, "fast")

    stop: ->
      killCMD = "kill " + @pid
      JekyllServer.consoleElement.append("Stopping Server... <i>(" + killCMD + ")</i><br />")
      JekyllServer.consoleElement.animate({"scrollTop": JekyllServer.consoleElement[0].scrollHeight}, "fast")

      childProcess.exec killCMD

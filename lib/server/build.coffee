childProcess = require 'child_process'

Builder =
  error: null

  build: (showUrl) ->
    buildCommand = (process.jekyllAtom.config?.atom?.buildCommand || process.jekyllAtom.buildCommand)

    atom.notifications.addInfo('Starting Jekyll Site Build')

    @buildProcess = childProcess.spawn buildCommand[0], buildCommand[1...], {cwd: atom.project.getPaths()[0], env: process.jekyllAtom.config?.atom?.buildEnv}

    @buildProcess.on 'error', (error) ->
      if error.code is 'ENOENT'
        atom.notifications.addError('Jekyll Binary Incorrect', {detail: "The Jekyll Binary #{error.path} is not valid.\r\nPlease go into Settings and change it"})
      else
        throw error

    @buildProcess.stdout.on 'data', (data) ->
      message = data.toString()
      if message.includes('Error:')
        Builder.error =  message

    @buildProcess.on 'exit', (code, signal) ->
      if code is 0
        if showUrl
          atom.notifications.addSuccess('Jekyll site build complete! View at http://localhost:' + atom.config.get('jekyll.serverPort'))
        else
          atom.notifications.addSuccess('Jekyll site build complete!')
      else
        atom.notifications.addError('Jekyll site build failed!', {detail: Builder.error})

module.exports = Builder

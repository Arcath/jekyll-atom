{Emitter} = require 'atom'
path = require 'path'

Utils = require '../lib/jekyll/utils'

describe 'Utils', ->
  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'sample')])

  it 'should get the config', (done) ->
    Main = {
      Emitter: new Emitter()
    }

    Main.Emitter.on 'config-loaded', ->
      done()

    Utils.getConfigFromSite()

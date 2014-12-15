{Emitter} = require 'atom'
path = require 'path'

describe 'Jekyll Server', ->
  [jekyllServer, emitter, reply, activationPromise, editor, editorView] = []

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'sample')])

    JekyllServer = require '../lib/server'
    emitter = new Emitter

    jekyllServer = new JekyllServer
    jekyllServer.activate(emitter)

    waitsForPromise ->
      atom.workspace.open('index.html')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      atom.config.set('jekyll.serverOptions', ['serve', '-w'])
      atom.config.set('jekyll.jekyllBinary', 'jekyll')

  describe 'using emitters', ->
    it 'should return a status', ->
      spy = jasmine.createSpy()

      emitter.on 'jekyll:server-status-reply', spy
      emitter.emit 'jekyll:server-status'

      waitsFor ->
        spy.callCount > 0

      runs ->
        expect(spy.mostRecentCall.args[0]).toBe 'Off'

    it 'should start the server', ->
      expect(jekyllServer.rawStatus()).toBe 'Off'
      emitter.emit 'jekyll:start-server'
      expect(jekyllServer.rawStatus()).toBe 'On'
      emitter.emit 'jekyll:stop-server'
      expect(jekyllServer.rawStatus()).toBe 'Off'


  describe 'directly', ->
    it 'should start the server', ->
      expect(jekyllServer.rawStatus()).toBe 'Off'
      jekyllServer.start()
      expect(jekyllServer.rawStatus()).toBe 'On'
      jekyllServer.stop()
      expect(jekyllServer.rawStatus()).toBe 'Off'

    it 'should have loaded the PWD', ->
      expect(jekyllServer.pwd).toBe path.join(__dirname, 'sample')

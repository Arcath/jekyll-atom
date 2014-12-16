{Emitter} = require 'atom'
path = require 'path'

describe 'Jekyll Server', ->
  [jekyllServer, emitter, reply, activationPromise, editor, editorView] = []

  beforeEach ->
    atom.project.setPaths([path.join(__dirname, 'sample')])

    JekyllServer = require '../lib/server'

    unless jekyllServer
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
      waitsFor ->
        jekyllServer.rawStatus() == 'Off'

      runs ->
        emitter.emit 'jekyll:start-server'
        waitsFor ->
          jekyllServer.rawStatus() == 'On'
        runs ->
          expect(jekyllServer.rawStatus()).toBe 'On'
          emitter.emit 'jekyll:stop-server'


  describe 'directly', ->
    it 'should start the server', ->
      waitsFor ->
        jekyllServer.rawStatus() == 'Off'

      runs ->
        jekyllServer.start()
        expect(jekyllServer.rawStatus()).toBe 'On'
        jekyllServer.stop()
        expect(jekyllServer.rawStatus()).toBe 'Off'

    it 'should have loaded the PWD', ->
      expect(jekyllServer.pwd).toBe path.join(__dirname, 'sample')

  describe 'the toggle command', ->
    it 'should start the server if not running', ->
      waitsFor ->
        jekyllServer.rawStatus() == 'Off'

      runs ->
        jekyllServer.toggle()

        waitsFor ->
          jekyllServer.rawStatus() == 'On'

        runs ->
          expect(jekyllServer.rawStatus()).toBe 'On'
          jekyllServer.stop()
          expect(jekyllServer.rawStatus()).toBe 'Off'

    it 'should stop the server if it is running', ->
      waitsFor ->
        jekyllServer.rawStatus() == 'Off'

      runs ->
        jekyllServer.start()

        waitsFor ->
          jekyllServer.rawStatus() == 'On'

        runs ->
          expect(jekyllServer.rawStatus()).toBe 'On'
          jekyllServer.toggle()
          expect(jekyllServer.rawStatus()).toBe 'Off'

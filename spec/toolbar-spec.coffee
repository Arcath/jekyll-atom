path = require 'path'
{$, $$} = require 'atom-space-pen-views'
fs = require 'fs-plus'

describe 'Jekyll Toolbar View', ->
  [activationPromise, editor, editorView, toolbar] = []

  beforeEach ->
    expect(atom.packages.isPackageActive('jekyll')).toBe false

    atom.project.setPaths([path.join(__dirname, 'sample')])

    workspaceElement = atom.views.getView(atom.workspace)

    waitsForPromise ->
      atom.workspace.open('index.html')

    runs ->
      jasmine.attachToDOM(workspaceElement)
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)


      activationPromise = atom.packages.activatePackage('jekyll')
      activationPromise.fail (reason) ->
        throw reason

  describe 'The View', ->
    beforeEach ->
      atom.commands.dispatch editorView, 'jekyll:toolbar'

      waitsForPromise ->
        activationPromise

      runs ->
        toolbar = $(atom.workspace.getBottomPanels()[0].getItem()).view()

    it 'should attach itself to the bottom', ->
      expect(toolbar).toExist()

    it 'should write messages to the console', ->
      spy = jasmine.createSpy()

      toolbar.console.html('Test...')
      toolbar.emitter.on 'jekyll:console-message', spy

      toolbar.emitter.emit 'jekyll:console-message', 'Successful'

      waitsFor ->
        spy.callCount > 0

      runs ->
        expect(spy.callCount).toBe 1
        expect(toolbar.console.html()).not.toBe 'Test...'

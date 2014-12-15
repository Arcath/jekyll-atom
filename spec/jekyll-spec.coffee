path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

describe 'Jekyll-Atom', ->
  [workspaceElement, editor, editorView, activationPromise] = []

  getToolbar = ->
    workspaceElement.querySelector('.jekyll-manager-panel')

  getStatusText = ->
    workspaceElement.querySelector('.jekyll-status-text')

  beforeEach ->
    expect(atom.packages.isPackageActive('jekyll')).toBe false

    atom.project.setPaths([path.join(__dirname, 'sample')])

    workspaceElement = atom.views.getView(atom.workspace)
    #atom.__workspaceView = workspaceElement

    waitsForPromise ->
      atom.workspace.open('index.html')

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView(editor)

      activationPromise = atom.packages.activatePackage('jekyll')
      activationPromise.fail (reason) ->
        throw reason

  describe 'Before Activation', ->
    it 'should not be active', ->
      expect(atom.packages.isPackageActive('jekyll')).toBe false

  describe 'when the toolbar is triggered', ->
    it 'should be active', ->
      atom.commands.dispatch editorView, 'jekyll:toolbar'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.packages.isPackageActive('jekyll')).toBe true

    it 'should have the toolbar open', ->
      atom.commands.dispatch editorView, 'jekyll:toolbar'

      waitsForPromise ->
        activationPromise.then ({mainModule}) ->
          expect(mainModule.toolbarView).not.toBe null
          expect(mainModule.toolbarPanel.isVisible()).toBe true


  describe 'when the manage view is opened', ->
    it 'should have opened', ->
      atom.commands.dispatch editorView, 'jekyll:manage'

      waitsForPromise ->
        activationPromise

  describe 'the open config command', ->

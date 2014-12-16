path = require 'path'

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

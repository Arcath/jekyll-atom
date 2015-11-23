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

  describe 'Before Activation', ->
    it 'should not be active', ->
      expect(atom.packages.isPackageActive('jekyll')).toBe false

  describe 'Buffer Functions', ->
    beforeEach ->
      atom.project.setPaths([path.join(__dirname, 'sample')])

    it 'should open a layout', ->
      waitsForPromise ->
        atom.workspace.open('index.html')

      runs ->
        relativePath = atom.workspace.getActiveTextEditor().buffer.file.path.replace(path.join(__dirname, 'sample'), '')

        expect(relativePath.replace('\\', '/')).toBe '/index.html'
        expect(atom.workspace.getTextEditors().length).toBe 1

        atom.commands.dispatch editorView, 'jekyll:open-layout'

        waitsForPromise ->
          activationPromise

        runs ->
          waitsFor ->
            atom.workspace.getTextEditors().length is 2

          runs ->
            relativePath = atom.workspace.getActiveTextEditor().buffer.file.path.replace(path.join(__dirname, 'sample'), '')

            expect(relativePath.replace(/\\/g, '/')).toBe '/_layouts/default.html'
            expect(atom.workspace.getTextEditors().length).toBe 2

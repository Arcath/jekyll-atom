path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

describe 'Jekyll', ->
  describe 'Before Activation', ->
    [workspaceElement] = []

    beforeEach ->
      directory = temp.mkdirSync()
      atom.project.setPaths([directory])

      workspaceElement = atom.views.getView(atom.workspace)
      atom.__workspaceView = {}

    it 'should not have a status bar item', ->
      expect(workspaceElement.querySelector('#jekyllStatusLink')).toBe null

    it 'should not be active', ->
      expect(atom.packages.isPackageActive('jekyll')).toBe false

  describe 'After Activation', ->
    [workspaceElement, activationPromise] = []

    beforeEach ->
      directory = temp.mkdirSync()
      atom.project.setPaths([directory])

      workspaceElement = atom.views.getView(atom.workspace)
      atom.__workspaceView = {}

      activationPromise = atom.packages.activatePackage('jekyll')
      activationPromise.fail (reason) ->
        console.log reason

      waitsForPromise ->
        activationPromise

    it 'should have activated', ->
      runs ->
        expect(atom.packages.isPackageActive('jekyll')).toBe true

    it 'should have added an item to the status bar', ->
      runs ->
        expect(workspaceElement.querySelector('#jekyllStatusLink')).not.toBe null

    describe 'when the toolbar is opened', ->
      it 'should put the toolbar in the bottom panel', ->
        atom.commands.dispatch editorView, 'jekyll:toolbar'

        runs ->
          expect(workspaceElement.querySelector('.jekyll-manager-panel')).toBeDefined()

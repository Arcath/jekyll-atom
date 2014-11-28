{$$, WorkspaceView} = require 'atom'
Jekyll = require '../lib/jekyll'

describe 'Jekyll', ->

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('jekyll')

  it 'Should open the config file', ->
    expect(atom.workspaceView.getEditorViews().length).toBe 0
    atom.workspaceView.trigger 'jekyll:open-config'
    expect(atom.workspaceView.getEditorViews().length).toBe 1

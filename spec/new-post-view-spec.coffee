path = require 'path'
{$, $$} = require 'atom-space-pen-views'
fs = require 'fs-plus'

describe 'Jekyll New Post View', ->
  [activationPromise, editor, editorView] = []

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


  describe 'the view', ->
    it 'should appear as a modal', ->
      atom.commands.dispatch editorView, 'jekyll:new-post'

      waitsForPromise ->
        activationPromise

      runs ->
        dialog = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(dialog).toExist()
        expect(dialog.promptText).toExist()
        expect(dialog.miniEditor).toHaveFocus()

    it 'should allow you to confirm the entry', ->
      atom.commands.dispatch editorView, 'jekyll:new-post'

      waitsForPromise ->
        activationPromise

      runs ->
        dialog = $(atom.workspace.getModalPanels()[0].getItem()).view()
        titleName = dialog.generateFileName('Jekyll New Post')
        fileName = atom.config.get('jekyll.postsDir') + titleName + atom.config.get('jekyll.postsType')
        pathToCreate = atom.project.getDirectories()[0]?.resolve(fileName)

        fs.unlinkSync(pathToCreate) if fs.existsSync(pathToCreate)

        expect(fs.existsSync(pathToCreate)).toBe false
        dialog.miniEditor.setText('Jekyll New Post')
        expect(dialog.miniEditor.getText()).toBe 'Jekyll New Post'
        atom.commands.dispatch dialog.element, 'core:confirm'
        expect(fs.existsSync(pathToCreate)).toBe true

        if fs.existsSync(pathToCreate)
          fileContents = fs.readFileSync(pathToCreate, {encoding: 'UTF-8'})

          expect(fileContents).toBe dialog.fileContents('Jekyll New Post', dialog.generateDateString())

          fs.unlinkSync(pathToCreate)
        else
          throw 'file not created'

  describe 'the functions', ->
    it 'should generate a date string and file name', ->
      atom.commands.dispatch editorView, 'jekyll:new-post'

      waitsForPromise ->
        activationPromise

      runs ->
        dialog = $(atom.workspace.getModalPanels()[0].getItem()).view()
        expect(dialog.generateDateString(new Date(0))).toBe '1970-01-01'
        expect(dialog.generateFileName('Jekyll New Post')).toBe dialog.generateDateString() + '-jekyll-new-post'

    it 'should create a post', ->
      atom.commands.dispatch editorView, 'jekyll:new-post'

      waitsForPromise ->
        activationPromise

      runs ->
        dialog = $(atom.workspace.getModalPanels()[0].getItem()).view()
        titleName = dialog.generateFileName('Jekyll New Post')
        fileName = atom.config.get('jekyll.postsDir') + titleName + atom.config.get('jekyll.postsType')
        pathToCreate = atom.project.getDirectories()[0]?.resolve(fileName)

        fs.unlinkSync(pathToCreate) if fs.existsSync(pathToCreate)

        expect(fs.existsSync(pathToCreate)).toBe false
        dialog.onConfirm('Jekyll New Post')
        expect(fs.existsSync(pathToCreate)).toBe true

        if fs.existsSync(pathToCreate)
          fileContents = fs.readFileSync(pathToCreate, {encoding: 'UTF-8'})

          expect(fileContents).toBe dialog.fileContents('Jekyll New Post', dialog.generateDateString())

          fs.unlinkSync(pathToCreate)
        else
          throw 'file not created'

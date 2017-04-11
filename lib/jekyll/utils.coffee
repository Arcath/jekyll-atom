fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

latinize = require 'latinize'

module.exports =
  Main: null

  setMainModule: (@Main) ->

  waitForConfig: (cb) ->
    if process.jekyllAtom.config
      cb(process.jekyllAtom.config)
    else
      @Main.disposables.push @Main.Emitter.on 'config-loaded', (conf) => cb(conf)

  getConfigFromSite: ->
    fs.open(
      path.join(atom.project.getPaths()[0], '_config.yml'),
      'r',
      (err, fd) => @handleConfigFileOpen(err, fd)
    )

  handleConfigFileOpen: (err, fd) ->
    unless err
      process.jekyllAtom.config = yaml.safeLoad(fs.readFileSync(path.join(atom.project.getPaths()[0], '_config.yml')))
      process.jekyllAtom.config.layouts_dir = './_layouts' unless process.jekyllAtom.config.layouts_dir
      process.jekyllAtom.config.includes_dir = './_includes' unless process.jekyllAtom.config.includes_dir
      process.jekyllAtom.config.data_dir = './_data' unless process.jekyllAtom.config.data_dir
      process.jekyllAtom.config.destination = './_site' unless process.jekyllAtom.config.destination
      process.jekyllAtom.config.source = '.' unless process.jekyllAtom.config.source
      process.jekyllAtom.config.postFileType = '.markdown' unless process.jekyllAtom.config.postFileType

      unless process.jekyllAtom.config.atom
        process.jekyllAtom.config.atom = {}

      process.jekyllAtom.config.atom.defaultPostDir = '_posts' unless process.jekyllAtom.config.atom.defaultPostDir

      unless process.jekyllAtom.config.atom.postDirs
        process.jekyllAtom.config.atom.postDirs = []

      process.jekyllAtom.config.atom.postDirs.unshift '_drafts'
      process.jekyllAtom.config.atom.postDirs.unshift '_posts'




      @Main.Emitter.emit 'config-loaded', process.jekyllAtom.config

  generateFileName: (title) ->
    title = latinize(title)
    titleString = encodeURI title.toLowerCase().replace(/[^\w\s\u0080-\uFFFF]|_/g, "").replace(RegExp(" ", 'g'),"-")
    return @generateDateString() + '-' + titleString

  generateDateString: (currentTime = new Date(), showTime = false) ->
    string = currentTime.getFullYear() +
      "-" +
      ("0" + (currentTime.getMonth() + 1)).slice(-2) +
      "-" +
      ("0" + currentTime.getDate()).slice(-2)

    if showTime
      string += " " +
      ("0" + currentTime.getHours()).slice(-2) +
      ":" +
      ("0" + currentTime.getMinutes()).slice(-2) +
      ":" +
      ("0" + currentTime.getSeconds()).slice(-2)

      timezoneOffset = currentTime.getTimezoneOffset()
      string += " " +
      (if timezoneOffset <= 0 then "+" else "-") +
      ("0" + Math.floor(Math.abs(timezoneOffset) / 60)).slice(-2) +
      ("0" + Math.abs(timezoneOffset) % 60).slice(-2)

    return string

  scan: (string, pattern) ->
    matches = []
    results = []
    while matches = pattern.exec(string)
      matches.shift();
      results.push(matches)

    return results

  getPostTitle: (editor) ->
    contents = editor.getText()
    title = @scan(contents, /title: (.*?)[\r\n|\n\r|\r|\n]/g)[0][0]

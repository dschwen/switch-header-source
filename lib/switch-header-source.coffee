$    = require 'jquery'
fs   = require 'fs-plus'
path = require 'path'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    fileRegex:
      type: 'string'
      default: '(.*)(\\.h(pp|xx)|\\.(hh|cc|mm)|\\.[mhcC]|\\.c(pp|xx))$'
      title: 'Tracked file regular expression'
      description: """Regular expression used to identify all files the plugin switches
                      between. The first capture group holds the common base name of the files."""
      order: 1
    samePane:
      type: 'boolean'
      default: false
      description: 'Keep header and source files in the same pane.'
      order: 2
    newTabPending:
      type: 'boolean'
      default: false
      description: 'Open new files as pending tabs.'
      order: 3

  active: false
  loadPathsTask: null
  subscriptions: null
  busyProvider: null
  switchMap: new Map
  projectPathsSubscription: null
  projectFilesSubscription: null

  activate: ->
    @subscriptions = new CompositeDisposable()
    # give the user a chance to install busy-signal
    require('atom-package-deps').install('switch-header-source').then =>
      # once it is installed continue with the activation
      atom.commands.add 'atom-workspace', 'switch-header-source:switch', => @switchNext()
      atom.commands.add 'atom-workspace', 'switch-header-source:switch-previous', => @switchPrevious()
      atom.config.onDidChange 'switch-header-source.fileRegex', (value) =>
        @createRegExp()
        @startLoadPathsTask()

      @createRegExp()

      @active = true
      process.nextTick () =>
        @startLoadPathsTask()

  deactivate: ->
    @subscriptions.dispose()

  consumeSignal: (registry) ->
    @busyProvider = registry.create()
    @subscriptions.add(@busyProvider)

  # match Tracked file regular expression to obtain key
  getKey: (filePath) ->
    base = path.basename filePath
    match = @fileRegex.exec base
    if match
      return match[1]
    return null

  # insert file path into the switch map
  switchMapAdd: (filePath) ->
    key = @getKey filePath
    if key
      entry = @switchMap.get(key) or []
      try
        realPath = fs.realpathSync(filePath)
        if entry.indexOf(realPath) < 0
          entry.push realPath
        @switchMap.set key, entry
      catch error
        console.log error

  # remove file path from the switch map
  switchMapDelete: (filePath) ->
    key = @getKey filePath
    if key
      entry = @switchMap.get key
      if entry
        try
          try
            filePath = fs.realpathSync filePath
          catch
            console.log filePath, 'has already disappeared'
          index = entry.indexOf filePath
          if index >= 0
            entry.splice index, 1
          @switchMap.set key, entry
        catch error
          console.log error

  startLoadPathsTask: ->
    @stopLoadPathsTask()

    return unless this.active or atom.project.getPaths().length == 0

    # get access to teh fuzzy-finder core package
    fuzzyFinder = atom.packages.getLoadedPackage('fuzzy-finder')
    if !fuzzyFinder
      atom.notifications.addError 'fuzzy-finder core package is missing, unable to index project.'
      return
    pathLoader = require(path.join(fuzzyFinder.path, 'lib/path-loader'))

    if @busyProvider
      @busyProvider.add('Indexing project')

    # start the path-loader task
    @loadPathsTask = pathLoader.startTask (projectPaths) =>
      @switchMap = new Map
      for filePath in projectPaths
        @switchMapAdd filePath

      if @busyProvider
        @busyProvider.clear()

    @projectPathsSubscription = atom.project.onDidChangePaths () =>
      @projectPaths = null
      @stopLoadPathsTask()

    @projectFilesSubscription = atom.project.onDidChangeFiles (events) =>
      for event in events
        if event.action == 'created'
          @switchMapAdd event.path

        if event.action == 'deleted'
          @switchMapDelete event.path

        if event.action == 'renamed'
          @switchMapDelete event.oldPath
          @switchMapAdd event.path

  stopLoadPathsTask: ->
    if @projectPathsSubscription != null
      @projectPathsSubscription.dispose()
    if @projectFilesSubscription != null
      @projectFilesSubscription.dispose()

    @projectPathsSubscription = null
    @projectFilesSubscription = null

    if @loadPathsTask != null
      @loadPathsTask.terminate()
    @loadPathsTask = null

    if @busyProvider
      @busyProvider.clear()

  createRegExp: ->
    try
      $('.file-regex-error')?.remove()
      fileRegexError = $('<span class="file-regex-error">Error in regular expression!</span>')
      $('#switch-header-source\\.fileRegex')?.after(fileRegexError)
      @fileRegex = new RegExp(atom.config.get('switch-header-source.fileRegex'))
      fileRegexError.remove()

    catch error
      @fileRegex = /(.*)(\.h(pp|xx)|\.(hh|cc|mm)|\.[mhcC]|\.c(pp|xx))$/

  # switch to the next file in the current cycle
  switchNext: ->
    @switch 1

  # switch to the previous file in the current cycle
  switchPrevious: ->
    @switch -1

  switch: (step) ->
    # Check if the active item is a text editor
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    # full path of the current file
    try
      filePath = fs.realpathSync(editor.getPath())

      # get the base name of the current file (if it matched the fileRegexp)
      key = @getKey filePath
      if key
        # get the list of matching files from the switchMap
        entry = @switchMap.get key
        # console.log entry
        if entry
          # find the current file's index in the entry..
          index = entry.indexOf filePath
          if index >= 0
            # ..and switch to the next one
            atom.workspace.open entry[(index + entry.length + step) % entry.length], {
              searchAllPanes: !atom.config.get('switch-header-source.samePane'),
              pending: atom.config.get('switch-header-source.newTabPending')
            }

    catch error
      console.log error

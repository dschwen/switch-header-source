$    = require 'jquery'
fs   = require 'fs-plus'
path = require 'path'

module.exports =
  config:
    headerFileRegex:
      type: 'string'
      default: '\\.h|\\.hpp|\\.hh|\\.hxx'
      title: 'Header file regular expression'
      description: """Regular expression used to identify "header" file
                      suffixes (matched at the end of the file name, remember
                      to escape \'.\')"""
      order: 1
    definitionFileRegex:
      type: 'string'
      default: '\\.[cC]|\\.cpp|\\.cc|\\.cxx|\\.m|\\.mm'
      title: 'Definition file regular expression'
      description: """Regular expression used to identify "definition" file
                      suffixes (matched at the end of the file name, remember
                      to escape \'.\')"""
      order: 2
    samePane:
      type: 'boolean'
      default: false
      description: 'Keep header and source files in the same pane.'
      order: 3

  file: null
  pathCache: {}

  activate: ->
    atom.commands.add 'atom-workspace', 'switch-header-source:switch', => @switch()
    atom.config.onDidChange 'switch-header-source.headerFileRegex', (value) => @createRegExp()
    atom.config.onDidChange 'switch-header-source.definitionFileRegex', (value) => @createRegExp()
    @createRegExp()

  createRegExp: ->
    try
      $('.header-regex-error')?.remove()
      headerRegexError = $('<span class="header-regex-error">Error in regular expression!</span>')
      $('#switch-header-source\\.headerFileRegex')?.after(headerRegexError)
      @headerRegex = new RegExp(
        '(.*)(' + atom.config.get('switch-header-source.headerFileRegex') + ')$'
      )
      headerRegexError.remove()

      $('.definition-regex-error')?.remove()
      defintionRegexError = $('<span class="header-regex-error">Error in regular expression!</span>')
      $('#switch-header-source\\.definitionFileRegex')?.after(defintionRegexError)
      @definitionRegex = new RegExp(
        '(.*)(' + atom.config.get('switch-header-source.definitionFileRegex') + ')$'
      )
      defintionRegexError.remove()
    catch error
      @headerRegex = /(.*)(\.h|\.hpp|\.hh|\.hxx)$/
      @definitionRegex = /(.*)(\.[cC]|\.cpp|\.cc|\.cxx|\.m|\.mm)$/

  switch: ->
    # Check if the active item is a text editor
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    @file = editor.getPath()

    # try the path cache for faster switching
    if @file of @pathCache and @pathCache[@file]? and fs.existsSync(@pathCache[@file])
      atom.workspace.open @pathCache[@file], { searchAllPanes: !atom.config.get('switch-header-source.samePane') }
      return

    dir  = path.dirname  @file
    name = path.basename @file

    if @headerRegex.test name
      if @findInDir(dir, name, @headerRegex, @definitionRegex) or
         @find(dir, name, 'include', 'src', @headerRegex, @definitionRegex)
        return

    if @definitionRegex.test name
      if @findInDir(dir, name, @definitionRegex, @headerRegex) or
         @find(dir, name, 'src', 'include', @definitionRegex, @headerRegex)
        return

  # find corresponding file in 'dir' directory
  findInDir: (dir, name, expressionA, expressionB) ->
    fullName = path.join dir, name.match(expressionA)[1]
    foundFile = null

    for fileName in fs.listSync(dir)
      match = fileName.match(expressionB)
      foundFile = fileName if match and match[1] == fullName and match[1] != path.join(dir, name)
      break if foundFile

    if foundFile
      atom.workspace.open foundFile, { searchAllPanes: !atom.config.get('switch-header-source.samePane') }
      @pathCache[@file] = foundFile

    foundFile

  # find corresponding file in alternate subtree
  find: (currentDir, name, upperBound, searchFrom, expressionA, expressionB) ->
    nodes = currentDir.split path.sep
    index = nodes.lastIndexOf upperBound
    return if index == -1
    nodes[index] = searchFrom
    perfectDir = nodes.join path.sep
    if not @findInDir perfectDir, name, expressionA, expressionB
      dir = nodes[0..index].join path.sep
      if not @findInDir dir, name, expressionA, expressionB
        fs.traverseTree dir, (->), ((d) => not @findInDir d, name, expressionA, expressionB), (->)

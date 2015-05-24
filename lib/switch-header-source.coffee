fs   = require 'fs-plus'
path = require 'path'

module.exports =
  config:
    headerFileRegex:
      type: 'string'
      default: '\\.h|\\.hpp|\\.hh|\\.hxx'
      description: """Regular expression to use to identify "header" file
                      suffixes (matched at the end of the file name, remember
                      to escape \'.\')"""
      order: 1
    definitionFileRegex:
      type: 'string'
      default: '\\.c|\\.cpp|\\.cc|\\.cxx|\\.m|\\.mm'
      description: """Regular expression to use to identify "definition" file
                      suffixes (matched at the end of the file name, remember
                      to escape \'.\')"""
      order: 2
    samePane:
      type: 'boolean'
      default: false
      description: 'Keep header and source files in the same pane.'
      order: 3

  activate: ->
    atom.commands.add 'atom-workspace', 'switch-header-source:switch', => @switch()

  switch: ->
    # Check if the active item is a text editor
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    file   = editor.getPath()

    headerRegex = new RegExp(
      '(.*)(' + atom.config.get('switch-header-source.headerFileRegex') + ')$',
      'i'
    )
    definitionRegex = new RegExp(
      '(.*)(' + atom.config.get('switch-header-source.definitionFileRegex') + ')$',
      'i'
    )

    dir  = path.dirname  file
    name = path.basename file

    if headerRegex.test name
      #console.log "header"
      #console.log name
      #console.log name.match(headerRegex)
      @name = name.match(headerRegex)
      if not @findInDir dir, definitionRegex
        @find dir, 'include', 'src', definitionRegex

    else if definitionRegex.test name
      #console.log "definition"
      #console.log name
      #console.log name.match(definitionRegex)
      @name = name.match(definitionRegex)
      if not @findInDir dir, headerRegex
        @find dir, 'src', 'include', headerRegex

  # find corresponding file in 'dir' directory
  findInDir: (dir, expression) ->
    #console.log @name
    #console.log @name[1]
    fullName = path.join dir, @name[1]
    #console.log fullName
    foundFile = null
    for fileName in fs.listSync(dir)
      #console.log "::: ", fileName
      if fs.isFileSync(fileName)
        #console.log "  : is a file"
        match = fileName.match(expression)
        foundFile = fileName if match and match[1] == fullName
        #console.log "  : FOUND MATCH" if foundFile
        #console.log "  :", foundFile if foundFile
        break if foundFile
    atom.workspace.open foundFile, { searchAllPanes: !atom.config.get('switch-header-source.samePane') } if foundFile
    foundFile

  # find corresponding file in alternate subtree
  find: (currentDir, upperBound, searchFrom, expression) ->
    #console.log "SUBTREE SEARCH"
    nodes = currentDir.split path.sep
    index = nodes.lastIndexOf upperBound
    return if index == -1
    nodes[index] = searchFrom
    dir = nodes[0..index].join path.sep
    if not @findInDir dir, expression
      fs.traverseTree dir, (->), ((d) => not @findInDir d, expression)

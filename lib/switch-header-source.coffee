fs   = require 'fs-plus'
path = require 'path'

module.exports =
  activate: ->
    atom.commands.add 'atom-text-editor', 'switch-header-source:switch', => @switch()

  switch: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActivePaneItem()
    file   = editor.getPath()

    dir  = path.dirname  file
    name = path.basename file
    ext  = path.extname  file

    @name = name.substring 0, name.lastIndexOf '.'

    if /\.h|\.hpp|\.hh|\.hxx/i.test ext
      @extensions = ['cpp', 'c', 'cc', 'cxx', 'C', 'm', 'mm']
      @find dir, 'include', 'src'  if not @findInDir dir

    else if /\.c|\.cpp|\.cc|\.cxx|\.m|\.mm/i.test ext
      @extensions = ['h', 'hpp', 'hxx', 'hh']
      @find dir, 'src', 'include'  if not @findInDir dir

  # find corresponding file in 'dir' directory
  findInDir: (dir) ->
    fullName = path.join dir, @name
    resolved = fs.resolveExtension fullName, @extensions
    atom.workspace.open resolved, { searchAllPanes: !atom.config.get('switch-header-source.samePane') } if resolved
    resolved

  # find corresponding file in alternate subtree
  find: (currentDir, upperBound, searchFrom) ->
    nodes = currentDir.split path.sep
    index = nodes.lastIndexOf upperBound
    return if index == -1
    nodes[index] = searchFrom
    dir = nodes[0..index].join path.sep
    fs.traverseTree dir, (->), ((d) => not @findInDir d) if not @findInDir dir

  config:
    samePane:
      type: 'boolean'
      default: false
      description: 'Keep header and source files in the same pane.'

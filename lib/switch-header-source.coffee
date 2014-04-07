module.exports =
  activate: ->
    atom.workspaceView.command "switch-header-source:switch", => @switch()

  switch: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    #path = editor.buffer.file.path
    path = editor.getUri()

    # go over each replacement rule set until one matches all sub rules
    # that is the one that gets applied
    replacements = [
      # .C -> .h
      [['\.C$','.h'],['\/src\/','/include/']],
      [['\.h$','.C'],['\/include\/','/src/']]
    ]

    src_path = /\/[Ss]rc\//
    inc_path = /\/[Ii]nclude\//

    csuffix = /\.(c|cc|c\+\+)$/i
    hsuffix = /\.(h|hh|h\+\+)$/i

    if csuffix.test path
      # construct header file path
      new_path = path.replace(csuffix, '.h').replace(src_path, '/include/')
    else if hsuffix.test path
      # construct src file path
      new_path = path.replace(hsuffix, '.C').replace(inc_path, '/src/')
    else
      # nothing to do here
      return

    # load file, but check if it is already open in any of the panes
    atom.workspaceView.open(new_path, {
      searchAllPanes: true
    })
    #.fail (response) ->

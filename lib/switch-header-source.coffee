fs = require 'fs-plus'

module.exports =
  activate: ->
    atom.commands.add 'atom-text-editor', 'switch-header-source:switch', => @switch()

  switch: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    #path = editor.buffer.file.path
    path = editor.getUri()

    # go over each replacement rule set until one matches all sub rules
    # that is the one that gets applied
    replacements = [
      # C++ rules with directory hierarchy
      [[/\.C$/, '.h'], [/\/src\//, '/include/']],
      [[/\.h$/, '.C'], [/\/include\//, '/src/']],
      [[/\.cc$/, '.h'], [/\/src\//, '/include/']],
      [[/\.h$/, '.cc'], [/\/include\//, '/src/']],
      [[/\.cpp$/, '.hpp'], [/\/src\//, '/include/']],
      [[/\.hpp$/, '.cpp'], [/\/include\//, '/src/']],
      [[/\.cpp$/, '.h'], [/\/src\//, '/include/']],
      [[/\.h$/, '.cpp'], [/\/include\//, '/src/']],
      # C++ rules without directory hierarchy
      [[/\.cpp$/, '.h']],
      [[/\.h$/, '.cpp']],
      [[/\.cc$/, '.h']],
      [[/\.h$/, '.cc']],
      [[/\.cc$/, '.hh']],
      [[/\.hh$/, '.cc']],
      # Objective-C and Objective-C++ rules
      [[/\.h$/, '.m']],
      [[/\.hh$/, '.mm']],
      [[/\.m$/, '.h']],
      [[/\.mm$/, '.hh']],
      # C rules with directory hierarchy
      [[/\.c$/, '.h'], [/\/src\//, '/include/']],
      [[/\.h$/, '.c'], [/\/include\//, '/src/']],
      # C rules without directory hierarchy
      [[/\.c$/, '.h']],
      [[/\.h$/, '.c']]
    ]

    # try each ruleset
    for ruleset in replacements
      new_path = path

      # every rule in the set must be applicable
      fail = false
      for rule in ruleset
        if rule[0].test new_path
          new_path = new_path.replace rule[0], rule[1]
        else
          fail = true

      # if no rule failed and the file exists, load it
      if not fail and fs.existsSync new_path
        # load file, but check if it is already open in any of the panes
        atom.workspace.open new_path, { searchAllPanes: true }

        # and our work is done
        return

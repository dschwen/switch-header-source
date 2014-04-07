SwitchHeaderSource = require '../lib/switch-header-source'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "SwitchHeaderSource", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('switchHeaderSource')

  describe "when the switch-header-source:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.switch-header-source')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'switch-header-source:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.switch-header-source')).toExist()
        atom.workspaceView.trigger 'switch-header-source:toggle'
        expect(atom.workspaceView.find('.switch-header-source')).not.toExist()

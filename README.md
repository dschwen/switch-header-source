# switch-header-source package

Quick switching between C/C++ header and source files.

Use ```Ctrl-Option-s``` to switch from a ```.h``` to the corresponding ```.C``` file.

The logic to achieve this is currently rather crude (employing regular expressions to replace path components ```/src/``` with ```/include/``` and vice versa).

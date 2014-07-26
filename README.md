# switch-header-source package

Quick switching between C, C++, Objective-C, and Objective-C++ header and source
files.

Use ```Ctrl-Option-s``` to switch from a ```.h``` to the corresponding ```.C``` file.

The logic that matches source and header consists of a list of rulesets
consisting of regular expression text replacement rules. A ruleset is applied to
the path if each of its rules produce a positive match **and** if the resulting
path points to an existing file.

The default ruleset can be found in the `replacements` array within
[switch-header-source.coffee](lib/switch-header-source.coffee).

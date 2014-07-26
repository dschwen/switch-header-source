# switch-header-source package

Quick switching between C, C++, Objective-C, and Objective-C++ header and source
files.

Use ```Ctrl-Option-s``` to switch from a ```.h``` to the corresponding ```.C``` file.

The logic that matches source and header consists of a list of rulesets
consisting of regular expression text replacement rules. A ruleset is applied to
the path if each of its rules produce a positive match **and** if the resulting
path points to an existing file.

The default ruleset contains rules:

```coffee
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
  # C rules with directory hierarchy
  [[/\.c$/, '.h'], [/\/src\//, '/include/']],
  [[/\.h$/, '.c'], [/\/include\//, '/src/']],
  # C rules without directory hierarchy
  [[/\.c$/, '.h']],
  [[/\.h$/, '.c']]
]
```

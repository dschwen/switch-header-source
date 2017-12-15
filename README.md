# switch-header-source package

Quick switching between corresponding C, C++, Objective-C, and Objective-C++
header and source files...

...Actually between any arbitrarily defined groups of files (as long as you can
match their filenames with a regular expression)!

For example:

* Switch between `.C`, `.h`, and `.md` files (for implementation, headers, and
  class documentation files)
* Switch between `.js`, `.html`, and `.css` files
* Your imagination is the limit.. if not, [file an issue](https://github.com/dschwen/switch-header-source/issues)!

![switching-in-action](http://i.imgur.com/TPJtS1n.gif)

# Usage

## Mac
Use `Ctrl-Option-s` to cycle forward though groups of matching files (
`Shift-Ctrl-Option-s` to cycle backwards).

## Linux, Windows
Use `Alt-o` to cycle forward though groups of matching files (`Shift-Alt-o` to
cycle backwards).

# Configuration

The plugin will match each file's name in the project using the [regular
expression](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions)
in the _Tracked file regular expression_ setting. If the file name matches it is
added to the group of files that shares the _first capture group_ (this is the
part of the regular expression that was matched in the first pair of
parenthesis).

Let's for example decipher the _Tracked file regular expression_ setting

```
(.*)\.(h|cpp)$
```

* the `(.*)` is the _first capture group_ in this expression (you will see that it
  will match the base name of each matching file).
* the `\.` will match a period (the dot that separates the base name from the
  file extension).
* the `(h|cpp)` means "match a literal `h` _or_ a `cpp` string" (those are the
  file extensions of the files we want to switch between - and you can specify as
  many here as you like, e.g. `(h|cpp|md)`).
* the `$` matches the end of the filename (with this we make sure that nothing else
  comes after the extension in the filename, like for example a `.bak` or `~`,
  which would cause the plugin to switch to backup files)

## Examples

* Switch between files with three different extensions (`.js`, `.html`, `.css`)
```
(.*)\.(js|html|css)$
```
* Switch between a series of files like `output_xi-0`, `output_xi-1`, `output_xi-2`,
  ... `output_xi-10`
```
(.*)-(\d+)$
```

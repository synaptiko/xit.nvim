# xit.nvim

Plugin to work with [[x]it!](https://xit.jotaen.net/) files. Uses [tree-sitter-xit](https://github.com/synaptiko/tree-sitter-xit).

## Features

TODO

## Installation

```
Plug 'synaptiko/xit.nvim'
```

then restart your nvim and run:

```
:PlugInstall
```

and add to you lua config part:
```
require("xit").setup
```

then restart once more and run:

```
:TSInstall xit
```

## Status

- [x] Filetype & tree-sitter config
- [ ] Add queries
	- [ ] Indentation
	- [ ] Basic highlighting
	- [ ] Group folding?
- [ ] Keymap to create a new task
- [ ] Keymap to toggle task status
- [ ] Keymap to jump between tasks
- [ ] Keymap to jump between groups?
- [ ] Quickly filter out all completed or unfinished tasks (should support groups too)?
- [ ] Improve the installation process if it's possible (I couldn't figure it out)

# xit.nvim

Plugin to work with [[x]it!](https://xit.jotaen.net/) files. Uses [tree-sitter-xit](https://github.com/synaptiko/tree-sitter-xit).

## Features

See [Status](#status) for now.

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
require("xit").setup {}
```

then restart once more and run:

```
:TSInstall xit
```

## Status

Work in progress, see more in:
[TODO.xit](./TODO.xit)

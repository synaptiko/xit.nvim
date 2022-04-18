# xit.nvim

Plugin to work with [[x]it!](https://xit.jotaen.net/) files. Uses [tree-sitter-xit](https://github.com/synaptiko/tree-sitter-xit).

## Features

### Video version
[![Features of xit.nvim plugin (v0.1)](https://img.youtube.com/vi/VrFdujDqeOA/default.jpg)](https://youtu.be/VrFdujDqeOA)

- customizable syntax highlighting (with tree-sitter)
- customizable key mappings
- jump between tasks (you can toggle if it's jumping between all tasks or only open and ongoing ones)
- jump between headlines
- toggle task status (forward & backward, anywhere on the task)
- create a new task (before/after the current line/task)
- create a new headline (before/after the current line/task)
- delete a task
- filter open and ongoing tasks (while keeping or cleaning headlines)
- filter checked tasks (while keeping or cleaning headlines)
- smart insert mode mapping of Enter and Shift+Enter
  - press Enter at the end of the task to create a new one below
  - press Shift+Enter to create indented line (for multiline tasks)

## Getting started

This plugin was written with usage of new features of [Neovim 0.7](https://github.com/neovim/neovim/releases/tag/v0.7.0).

__No support for Vim is planned. Check [vim-xit](https://github.com/ryanolsonx/vim-xit) instead.__

### Installation

Use your favorite plugin manager, ie. `vim-plug`:
```
Plug 'synaptiko/xit.nvim'
```

then source your `init.vim`/`init.lua` (or restart your nvim) and run:
```
:PlugInstall
```

and initialize the plugin with the following lua line (for available options see [Configuration/Options](#options)):
```
require("xit").setup {}
```

then source or restart once more and run:
```
:TSInstall xit
```

Now you should be ready to load `*.xit` files and use all the features of this plugin.

### Configuration

#### Options

Default values:
```lua
local options = {
  disable_default_highlights = false,
  disable_default_mappings = false,
  default_jump_group = "all", -- possible values: all, open_and_ongoing
  wrap_jumps = true,
  in_development = false
}
```

You can adjust the options in `setup` function.

#### Highlighting

By default there is ready-to-use syntax highlighting which uses some of the existing highlight groups. But if it doesn't look well with your colorscheme or if you wish to use different colors/styles, feel free to disable the defaults with `disable_default_highlights = true` and then you can use the following highlight groups:
```
XitHeadline

XitOpenCheckbox
XitOpenTaskMainLine
XitOpenTaskOtherLine
XitOpenTaskPriority

XitOngoingCheckbox
XitOngoingTaskMainLine
XitOngoingTaskOtherLine
XitOngoingTaskPriority

XitCheckedCheckbox
XitCheckedTaskMainLine
XitCheckedTaskOtherLine
XitCheckedTaskPriority

XitObsoleteCheckbox
XitObsoleteTaskMainLine
XitObsoleteTaskOtherLine
XitObsoleteTaskPriority
```

#### Mappings

##### Default keymaps

**Normal mode:**

- `<C-n>` jump to next task
- `<C-p>` jump to previous task
- `<C-S-n>` jump to next headline
- `<C-S-p>` jump to previous headline
- `<C-t>` toggle checkbox (open -> ongoing -> checked -> obsolete)
- `<C-S-t>` toggle checkbox (obsolete -> checked -> ongoing -> open)
- `<leader>n` create new task (below the current line/task)
- `<leader>N` create new task (above the current line/task)
- `<leader>m` create new headline (below the current line/task)
- `<leader>M` create new headline (above the current line/task)
- `<leader>t` toggle jumps (all tasks or open and ongoing tasks)
- `<leader>x` delete task
- `<leader>fo` filter open and ongoing tasks
- `<leader>fc` filter checked tasks

**Insert mode:**

- `<CR>` creates new task (contains logic which understands if you are at the end of the task/headline etc.)
- `<S-CR>` creates indented line

##### Custom keymaps

If you want to configure them on your own, feel free to use `disable_default_mappings = true` and use [any function exported by `xit` module](./lua/xit.init.lua) (at the bottom of the file, look for `M.* = function` lines).

## Roadmap

See also [Roadmap.xit](./Roadmap.xit).

### 0.1 (Released)

Basic functionality and the plugin is ready for daily usage.

### 0.2 (WIP)

Support for tags syntax highlighting and filtering tasks by tags.

### 0.3

Support for due dates syntax highlighting and filtering tasks by the date.

### 0.4

Write tests and add better mappings configuration. Add task sorting capabilities.

### 0.5

Use floating windows to show filtered results. Interactive filtering capabilities.

### 0.6

Investigate divider support (will need spec. change and `tree-sitter-xit` support).

### 1.0

The plugin is fully tested and has all the goodies.

## Contributing

Any contributions are welcome (check [the list above](#roadmap) to see open/ongoing tasks).

If you are an experienced neovim plugin author or lua developer, I welcome your suggestions when it comes to the code & best practice.

There is also a discussion thread about this plugin: https://github.com/jotaen/xit/discussions/26

You can also check [recommended learning resources](./LearningResources.md) and [ideas](./Ideas.md).

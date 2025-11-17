# LazyVim Keybindings Cheat Sheet
**Leader key:** `<Space>` (you already have `vim.g.mapleader = " "`)

| Category               | Keybinding              | Description                                      |
|------------------------|-------------------------|--------------------------------------------------|
| **General**            | `<Space>`               | Press once → Which-key shows all leader commands |
|                        | `<C-s>`                 | Save file                                        |
|                        | `<C-q>`                 | Quit (close window)                              |
| **Files & Navigation** | `<Space>e`              | Toggle Neo-Tree (file explorer)                  |
|                        | `<Space>ff`             | Find files (Telescope)                           |
|                        | `<Space>fr`             | Recently opened files                            |
|                        | `<Space>fo`             | Old files (project history)                      |
|                        | `<Space>fb`             | Browse open buffers                              |
| **Search**             | `<Space>fg`             | Live grep (search in project)                    |
|                        | `<Space>fw`             | Find word under cursor                           |
|                        | `<Space>/`              | Search in current buffer (Telescope)             |
| **Harpoon (quick jump)** | `<Space>a`            | Mark current file                                |
|                        | `<Space>1` … `<Space>9` | Jump to marked file 1–9                          |
|                        | `<Space>hh`             | Harpoon quick menu                               |
| **LSP / Code**         | `gd`                    | Go to definition                                 |
|                        | `gD`                    | Go to declaration                                |
|                        | `gr`                    | Show references                                  |
|                        | `gi`                    | Go to implementation                             |
|                        | `K`                     | Hover documentation                              |
|                        | `<Space>ca`             | Code actions (fix, refactor, etc.)               |
|                        | `<Space>cr`             | Rename symbol                                    |
|                        | `<Space>cf`             | Format document                                  |
| **Git**                | `<Space>gs`             | Git status (fugitive)                            |
|                        | `<Space>gb`             | Git blame line                                   |
|                        | `]c` / `[c`             | Next / previous git hunk                         |
|                        | `<Space>hp`             | Preview hunk                                     |
| **Terminal**           | `<C-/>` or `<Space>t`   | Toggle floating terminal                         |
| **Buffers & Tabs**     | `<Space>bd`             | Close current buffer                             |
|                        | `<Space>bb`             | Switch buffer (Telescope)                        |
|                        | `<S-h>` / `<S-l>`       | Previous / next buffer (built-in)                |
| **Windows**            | `<C-h/j/k/l>`           | Move between window splits                       |
|                        | `<Space>ww`             | Other window                                     |
|                        | `<Space>wv`             | Vertical split                                   |
|                        | `<Space>ws`             | Horizontal split                                 |
| **Plugin Managers**    | `<Space>l`              | Open Lazy (plugin manager)                       |
|                        | `<Space>cm`             | Open Mason (install LSPs, linters, formatters)   |
| **Misc**               | `<Space>ud`             | Toggle diagnostics                               |
|                        | `<Space>un`             | Toggle line numbers                              |
|                        | `<Space>gg`             | LazyGit (floating git TUI)                       |

*All keybindings work out of the box with your current `configuration.nix` setup (November 2025).  
If you ever add more extras (like `noice.nvim`, `dap`, etc.), new bindings will automatically appear in Which-key.*

Feel free to keep this file in your dotfiles repo, Obsidian vault, or anywhere you like — it will stay accurate for your exact LazyVim installation!

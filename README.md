# Neovim Config — Reference Guide

A from-scratch Neovim IDE setup. Cross-platform (Windows + macOS). Built on `lazy.nvim`.

---

## Installation on a New Machine

### Dependencies

**macOS (Homebrew):**
```bash
brew install neovim git ripgrep fd zig
brew install --cask alacritty font-jetbrains-mono-nerd-font
```

**Windows (Scoop):**
```powershell
scoop install neovim git ripgrep fd zig pwsh
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF
scoop install alacritty
```

### Clone Config

**macOS:**
```bash
git clone git@github.com:nebulous-code/nvim-config.git ~/.config/nvim
```

**Windows:**
```powershell
git clone git@github.com:nebulous-code/nvim-config.git $env:LOCALAPPDATA\nvim
```

Open Neovim — `lazy.nvim` will bootstrap itself and install all plugins automatically on first launch.

### Environment Variables (Windows only)

Run the included setup script once to create handy shortcuts:
```powershell
.\setup-env.ps1
```

This sets:
- `$env:NVIM` → your nvim config folder
- `$env:NVIM_PLUGINS` → your plugins folder
- `$env:NVIM_DATA` → nvim data folder (Mason, lazy cache)

---

## Folder Structure

```
nvim/
├── init.lua              # Entry point — keymaps, settings, lazy bootstrap
├── setup-env.ps1         # Windows env variable setup script
└── lua/
    └── plugins/
        ├── alpha.lua         # Splash screen
        ├── autopairs.lua     # Auto-close brackets
        ├── bufferline.lua    # Visual tab bar
        ├── colorscheme.lua   # Theme (Melange)
        ├── completion.lua    # Autocomplete
        ├── diffview.lua      # Side-by-side git diff
        ├── filetree.lua      # File explorer sidebar
        ├── gitsigns.lua      # Git gutter indicators
        ├── lsp.lua           # Language servers
        ├── lualine.lua       # Status bar
        ├── neogit.lua        # Git UI panel
        ├── telescope.lua     # Fuzzy finder
        ├── treesitter.lua    # Syntax highlighting
        ├── which-key.lua     # Keybind popup
        └── yanky.lua         # Yank history
```

---

## Leader Key

The leader key is `Space`. All `<leader>` keybinds below mean press `Space` first.

Press `Space` and pause to see a which-key popup listing all available keybinds.

---

## Global Keybinds

| Key | Action |
|-----|--------|
| `u` | Undo |
| `U` | Redo |
| `gd` | Go to definition |
| `K` | Show hover documentation |
| `p` | Paste after cursor (uses yank history) |
| `P` | Paste before cursor (uses yank history) |

---

## Leader Keybind Groups

### `<leader>f` — Find (Telescope)

| Key | Action |
|-----|--------|
| `Space ff` | Find file by name |
| `Space fd` | Search text across all files (live grep) |
| `Space fb` | Browse open buffers |
| `Space fh` | Search help tags |
| `Space fgs` | Git status (changed files) |
| `Space fgb` | Git branches |
| `Space fgc` | Git commit history |

### `<leader>w` — Windows

| Key | Action |
|-----|--------|
| `Space w\|` | Vertical split |
| `Space w-` | Horizontal split |
| `Space wh` | Navigate to left split |
| `Space wl` | Navigate to right split |
| `Space wj` | Navigate to lower split |
| `Space wk` | Navigate to upper split |
| `Space wd` | Close current split |

Window navigation also works from terminal mode using the same keys.

### `<leader>b` — Buffers

| Key | Action |
|-----|--------|
| `Space bn` | New empty buffer |
| `Space bd` | Delete current buffer |
| `Space bl` | Next buffer (bufferline) |
| `Space bh` | Previous buffer (bufferline) |
| `Space bf` | Browse open buffers (Telescope) |

### `<leader>d` — Diagnostics

| Key | Action |
|-----|--------|
| `Space dd` | Show diagnostic detail for current line |
| `Space da` | Show all diagnostics in a list |
| `Space d]` | Jump to next diagnostic |
| `Space d[` | Jump to previous diagnostic |

### `<leader>g` — Git

| Key | Action |
|-----|--------|
| `Space gg` | Open Neogit panel |
| `Space gd` | Open Diffview (side-by-side diff) |
| `Space gh` | File history in Diffview |
| `Space gx` | Close Diffview |
| `Space gb` | Blame current line |
| `Space gp` | Preview hunk (inline diff popup) |
| `Space gs` | Stage hunk under cursor |
| `Space gu` | Undo staged hunk |
| `Space gS` | Stage entire buffer |
| `Space gR` | Reset entire buffer |
| `]h` | Next git hunk |
| `[h` | Previous git hunk |

### `<leader>p` — Plugins

| Key | Action |
|-----|--------|
| `Space pl` | Open Lazy plugin manager |
| `Space pm` | Open Mason language server manager |

### `<leader>y` — Yank History

| Key | Action |
|-----|--------|
| `Space y` | Open full yank history picker |
| `]y` | Cycle forward through yank history after pasting |
| `[y` | Cycle backward through yank history after pasting |

### Other Leader Keys

| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree sidebar |
| `Space rn` | Rename symbol (LSP) |
| `Space ca` | Code actions (LSP) |
| `Space t` | Launch Terminal (:terminal) |

---

## Terminal

Open a terminal inside Neovim:
```
:terminal
```

| Key | Action |
|-----|--------|
| `Esc` | Exit terminal mode → normal mode |
| `Space wh/l/j/k` | Navigate to another split from terminal |
| `i` or `a` | Return to terminal mode from normal mode |

The terminal uses `pwsh` on Windows and `zsh` on macOS automatically.

---

## Neogit — Git Panel

Open with `Space gg`. This is your main git workflow panel — shows untracked, unstaged, and staged changes.

### Navigation
| Key | Action |
|-----|--------|
| `j / k` | Move up/down |
| `l` or `h` | Toggle section open/closed |
| `Enter` | Open file in Diffview |
| `q` | Close Neogit |
| `?` | Show all available keybinds |

### Common Actions
| Key | Action |
|-----|--------|
| `s` | Stage file or hunk under cursor |
| `u` | Unstage |
| `c` | Open commit message buffer |
| `P` | Push (capital P) |
| `F` | Pull menu |
| `x` | Discard changes |
| `Tab` | Open log popup |

### Commit Buffer
Write your commit message, then:
- `:wq` — save and commit
- `:q!` — cancel commit

### Push Menu (after pressing `P`)
- `-u` — push to current remote (origin)
- `e` — push to a different remote

---

## Diffview — Side-by-Side Diff

Open with `Space gd`. Shows all changed files in a panel on the left with a side-by-side diff on the right.

| Key | Action |
|-----|--------|
| `j / k` | Navigate files in the panel |
| `Enter` | Open diff for selected file |
| `q` or `Space gx` | Close Diffview |

Open file history with `Space gh` — shows every commit that touched the current file with diffs for each.

---

## Telescope — Fuzzy Finder

Telescope opens a popup with a live-filtering search. Most pickers open in insert mode so you can start typing immediately. Buffer picker opens in normal mode for `j/k` navigation.

| Key | Action |
|-----|--------|
| `Tab` | Move down the list |
| `Shift+Tab` | Move up the list |
| `Enter` | Open selected item |
| `Esc` | Close picker |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+x` | Open in horizontal split |

---

## LSP — Language Servers

Active for: TypeScript/JavaScript, Python, Lua, Rust.

Language servers are installed and managed via Mason (`:Mason` or `Space pm`).

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Show documentation for symbol under cursor |
| `Space rn` | Rename symbol across all files |
| `Space ca` | Show code actions (imports, fixes, refactors) |
| `Space dd` | Show error/warning detail for current line |

---

## Completion — Autocomplete

Suggestions appear automatically as you type in insert mode.

| Key | Action |
|-----|--------|
| `Tab` | Select next suggestion |
| `Shift+Tab` | Select previous suggestion |
| `Enter` | Confirm selection |
| `Ctrl+Space` | Manually trigger suggestions |

---

## File Tree

Toggle with `Space e`.

| Key | Action |
|-----|--------|
| `Enter` | Open file |
| `a` | Create new file (add `/` at end to create folder) |
| `d` | Delete file |
| `r` | Rename file |
| `q` | Close tree |

Git status icons in the tree:
- `~` — modified, not staged
- `✓` — staged
- `?` — untracked
- `✗` — deleted

---

## Bufferline

The visual tab bar at the top of the screen showing all open files.

| Key | Action |
|-----|--------|
| `Space bl` | Next buffer |
| `Space bh` | Previous buffer |
| `Space bd` | Close current buffer |

---

## Yank History

Yanky extends Neovim's clipboard with a full history of everything you've copied.

1. Copy something with `y`
2. Paste with `p`
3. Press `]y` repeatedly to cycle through older yanks
4. Press `Space y` to see the full history and pick from it

Yanks are shared with your system clipboard — anything copied outside Neovim is also pasteable with `p`.

---

## Editor Settings

| Setting | Value |
|---------|-------|
| Indentation | 2 spaces |
| Tab characters | Converted to spaces |
| Line numbers | Relative (current line shows real number) |
| Clipboard | Synced with system clipboard |
| Auto-closing brackets | Enabled in insert mode |
| Background | Transparent (shows terminal/wallpaper through) |

---

## Theme

Currently using **Melange** — a warm dark colorscheme. Kanagawa is also installed and can be activated by uncommenting its config block in `colorscheme.lua` and commenting out the Melange one.

To preview themes without committing:
```
:Telescope colorscheme
```

---

## Updating Plugins

```
:Lazy sync
```

Or open `:Lazy` and press `U` to update all plugins.

## Updating Language Servers

Open `:Mason` and press `U` to update all installed language servers.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Icons show as squares | Nerd Font not set in terminal config |
| LSP not working | Run `:LspInfo` to see what's attached |
| Plugin errors on startup | Run `:Lazy` and press `R` to reinstall |
| General issues | Run `:checkhealth` for a full diagnosis |
| Treesitter errors | Run `:Lazy build nvim-treesitter` |

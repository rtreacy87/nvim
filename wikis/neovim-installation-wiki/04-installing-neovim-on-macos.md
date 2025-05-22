# Installing Neovim on macOS

This guide covers various methods to install Neovim on macOS, from package managers to building from source.

## Prerequisites

Before installing Neovim on macOS, ensure you have:

- macOS 10.15 (Catalina) or newer (recommended)
- Administrator privileges
- Internet connection
- Basic familiarity with Terminal

## Installation Methods

### Method 1: Using Homebrew (Recommended)

[Homebrew](https://brew.sh/) is the most popular package manager for macOS and provides an easy way to install Neovim.

1. **Install Homebrew** (if not already installed):
   - Open Terminal
   - Run:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   - Follow the prompts to complete installation

2. **Install Neovim**:
   ```bash
   brew install neovim
   ```

3. **Verify installation**:
   ```bash
   nvim --version
   ```

4. **Update Neovim** (when needed):
   ```bash
   brew update
   brew upgrade neovim
   ```

### Method 2: Using MacPorts

[MacPorts](https://www.macports.org/) is another package manager for macOS.

1. **Install MacPorts** (if not already installed):
   - Download the installer from [MacPorts website](https://www.macports.org/install.php)
   - Follow the installation instructions

2. **Install Neovim**:
   ```bash
   sudo port install neovim
   ```

3. **Verify installation**:
   ```bash
   nvim --version
   ```

4. **Update Neovim** (when needed):
   ```bash
   sudo port selfupdate
   sudo port upgrade neovim
   ```

### Method 3: Using Pre-built Binary

You can download and install a pre-built binary directly.

1. **Download the latest stable release**:
   ```bash
   curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-macos.tar.gz
   ```

2. **Extract the archive**:
   ```bash
   tar xzf nvim-macos.tar.gz
   ```

3. **Move to a directory in your PATH**:
   ```bash
   sudo mv nvim-macos /opt/
   sudo ln -s /opt/nvim-macos/bin/nvim /usr/local/bin/nvim
   ```

4. **Verify installation**:
   ```bash
   nvim --version
   ```

### Method 4: Building from Source

Building from source gives you the latest features and allows for customization.

1. **Install build dependencies**:
   ```bash
   # Using Homebrew
   brew install ninja libtool automake cmake pkg-config gettext curl
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/neovim/neovim.git
   cd neovim
   ```

3. **Build and install**:
   ```bash
   make CMAKE_BUILD_TYPE=Release
   sudo make install
   ```

4. **Verify installation**:
   ```bash
   nvim --version
   ```

## Post-Installation Setup

### Setting Up Configuration Directories

Create the necessary directories for Neovim configuration:

```bash
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site
```

### Creating a Basic Configuration

Create a basic `init.lua` file:

```bash
cat > ~/.config/nvim/init.lua << 'EOF'
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  pattern = '*',
})
EOF
```

### Installing a Terminal Emulator

For the best Neovim experience on macOS, consider using one of these terminal emulators:

1. **iTerm2** (Recommended):
   ```bash
   brew install --cask iterm2
   ```

2. **Alacritty**:
   ```bash
   brew install --cask alacritty
   ```

3. **Kitty**:
   ```bash
   brew install --cask kitty
   ```

### Installing a Nerd Font

For proper icon support in Neovim plugins:

```bash
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

Then configure your terminal to use the Nerd Font.

## macOS-Specific Considerations

### Clipboard Integration

Neovim on macOS should work with the system clipboard out of the box. If you experience issues:

1. **Check clipboard provider**:
   - Inside Neovim, run:
   ```
   :checkhealth provider
   ```

2. **Install pbcopy/pbpaste** (should be pre-installed on macOS):
   ```bash
   # If somehow missing, reinstall the command line tools
   xcode-select --install
   ```

### Python Integration

For Python support in Neovim:

1. **Install Python**:
   ```bash
   brew install python
   ```

2. **Install pynvim**:
   ```bash
   pip3 install pynvim
   ```

3. **Configure Neovim to use the correct Python**:
   Add to your `init.lua`:
   ```lua
   vim.g.python3_host_prog = '/usr/local/bin/python3'  -- Adjust path if needed
   ```

### Node.js Integration

For Node.js support (required by some plugins):

1. **Install Node.js**:
   ```bash
   brew install node
   ```

2. **Install neovim npm package**:
   ```bash
   npm install -g neovim
   ```

## Troubleshooting Common Issues

### Command Not Found

If `nvim` command is not recognized after installation:

1. **Check PATH**:
   ```bash
   echo $PATH
   ```

2. **Locate nvim binary**:
   ```bash
   which nvim
   ```

3. **Add to PATH if needed**:
   Add to your `~/.zshrc` or `~/.bash_profile`:
   ```bash
   export PATH="/path/to/nvim/bin:$PATH"
   ```

### Permission Issues

If you encounter permission issues:

1. **Fix permissions**:
   ```bash
   sudo chown -R $(whoami) /usr/local/bin /usr/local/share
   ```

2. **Use Homebrew without sudo**:
   ```bash
   # Recommended approach
   brew install neovim
   ```

### Homebrew Installation Issues

If Homebrew installation fails:

1. **Check system requirements**:
   - Ensure you're running a supported macOS version

2. **Fix Homebrew permissions**:
   ```bash
   sudo chown -R $(whoami) /usr/local/Homebrew
   ```

3. **Try alternative installation**:
   ```bash
   # Alternative Homebrew installation command
   NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

## GUI Options for macOS

### Neovide

[Neovide](https://github.com/neovide/neovide) is a graphical user interface for Neovim:

```bash
brew install --cask neovide
```

### VimR

[VimR](https://github.com/qvacua/vimr) is a native macOS GUI for Neovim:

```bash
brew install --cask vimr
```

## Next Steps

Now that you have Neovim installed on macOS, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore [Upgrading Neovim](06-upgrading-neovim.md)
- Set up a plugin manager and start customizing your Neovim experience

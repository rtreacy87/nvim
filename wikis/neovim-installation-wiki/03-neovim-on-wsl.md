# Neovim on WSL (Windows Subsystem for Linux)

This guide covers setting up and using Neovim in the Windows Subsystem for Linux (WSL), which combines the Windows environment with Linux capabilities.

## Why Use Neovim on WSL?

WSL offers several advantages for Neovim users:

- Native Linux environment on Windows
- Better compatibility with Unix-based tools and plugins
- Improved performance for certain operations
- Access to both Windows and Linux filesystems
- Easier setup for development environments

## Prerequisites

Before setting up Neovim on WSL, ensure you have:

- Windows 10 version 2004+ or Windows 11
- Administrator privileges
- 8GB+ RAM recommended
- At least 5GB of free disk space

## Installing WSL

### Method 1: Simple Installation (Windows 11 or Windows 10 version 2004+)

1. **Open PowerShell or Command Prompt as Administrator**

2. **Install WSL with Ubuntu** (default distribution):
   ```powershell
   wsl --install
   ```

3. **Restart your computer** when prompted

4. **Complete Ubuntu setup**:
   - After restart, a Ubuntu window will open automatically
   - Create a username and password when prompted

### Method 2: Manual Installation (Older Windows 10 versions)

1. **Enable WSL feature**:
   - Open PowerShell as Administrator
   - Run:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **Restart your computer**

3. **Download and install the WSL2 Linux kernel update**:
   - Download from [Microsoft's WSL page](https://aka.ms/wsl2kernel)
   - Run the installer

4. **Set WSL2 as default**:
   ```powershell
   wsl --set-default-version 2
   ```

5. **Install Ubuntu**:
   - Open Microsoft Store
   - Search for "Ubuntu"
   - Click "Get" or "Install"
   - Launch Ubuntu and complete the setup

### Upgrading to WSL2 (if you have WSL1)

If you already have WSL1 installed:

1. **Check your WSL version**:
   ```powershell
   wsl -l -v
   ```

2. **Convert to WSL2**:
   ```powershell
   wsl --set-version Ubuntu 2
   ```

## Installing Neovim on WSL

### Method 1: Using Package Manager (Ubuntu/Debian)

1. **Update package lists**:
   ```bash
   sudo apt update
   ```

2. **Install Neovim**:
   ```bash
   sudo apt install neovim
   ```

   Note: The version in the default repositories may be outdated. For a newer version, see Method 2 or 3.

### Method 2: Using PPA (Ubuntu)

For a more recent version:

1. **Add the PPA**:
   ```bash
   sudo add-apt-repository ppa:neovim-ppa/stable
   sudo apt update
   ```

2. **Install Neovim**:
   ```bash
   sudo apt install neovim
   ```

### Method 3: Using AppImage

For the latest stable version:

1. **Install required dependencies**:
   ```bash
   sudo apt install fuse libfuse2
   ```

2. **Download the AppImage**:
   ```bash
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
   ```

3. **Make it executable**:
   ```bash
   chmod u+x nvim.appimage
   ```

4. **Move to a directory in your PATH**:
   ```bash
   sudo mkdir -p /opt/nvim
   sudo mv nvim.appimage /opt/nvim/nvim
   sudo ln -s /opt/nvim/nvim /usr/local/bin/nvim
   ```

### Method 4: Building from Source

For the absolute latest version:

1. **Install build dependencies**:
   ```bash
   sudo apt update
   sudo apt install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl
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

## Configuring Neovim on WSL

### Configuration Location

In WSL, Neovim configuration follows Linux conventions:

- Main config: `~/.config/nvim/init.lua` or `~/.config/nvim/init.vim`
- Data directory: `~/.local/share/nvim/`
- State directory: `~/.local/state/nvim/`

Create the necessary directories:

```bash
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site
```

### Setting Up a Basic Configuration

Create a basic `init.lua`:

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

## Clipboard Integration

### Setting Up Clipboard Sharing

To share clipboard between WSL and Windows:

1. **Install win32yank** (recommended method):
   ```bash
   curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
   unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
   chmod +x /tmp/win32yank.exe
   sudo mv /tmp/win32yank.exe /usr/local/bin/
   ```

2. **Configure Neovim to use win32yank**:
   Add to your `init.lua`:
   ```lua
   vim.g.clipboard = {
     name = 'win32yank',
     copy = {
       ['+'] = 'win32yank.exe -i --crlf',
       ['*'] = 'win32yank.exe -i --crlf',
     },
     paste = {
       ['+'] = 'win32yank.exe -o --lf',
       ['*'] = 'win32yank.exe -o --lf',
     },
     cache_enabled = 0,
   }
   ```

## GUI Options with WSL

You can use Neovim in WSL with various GUI options:

### Option 1: Windows Terminal

1. **Install Windows Terminal** from the Microsoft Store

2. **Configure Windows Terminal**:
   - Open Settings (Ctrl+,)
   - Find your WSL distribution profile
   - Set the starting directory to your WSL home if needed
   - Customize font to a Nerd Font for better icon support

### Option 2: WSL with X Server

To use native Linux GUI applications:

1. **Install an X Server** on Windows:
   - [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
   - [Xming](http://www.straightrunning.com/XmingNotes/)

2. **Configure WSL to use the X Server**:
   Add to your `~/.bashrc` or `~/.zshrc`:
   ```bash
   export DISPLAY=:0
   ```

3. **Install a GUI Neovim wrapper**:
   ```bash
   sudo apt install neovim-qt
   # or
   sudo apt install neovim-gtk
   ```

### Option 3: Neovide

[Neovide](https://github.com/neovide/neovide) is a graphical user interface for Neovim:

1. **Install Neovide on Windows**

2. **Configure it to use WSL Neovim**:
   - In Neovide settings, set:
   ```
   wsl --distribution Ubuntu -- nvim
   ```

## Working with Files Between Windows and WSL

### Accessing Windows Files from WSL

Windows drives are mounted in WSL at `/mnt/`:

```bash
# Access C: drive
cd /mnt/c/

# Access your Windows user directory
cd /mnt/c/Users/YourUsername/
```

### Accessing WSL Files from Windows

Access WSL files from Windows using the `\\wsl$\` path:

1. **In File Explorer**, enter:
   ```
   \\wsl$\Ubuntu
   ```

2. **Create shortcuts** to frequently used WSL locations

## Next Steps

Now that you have Neovim running on WSL, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore [Upgrading Neovim](06-upgrading-neovim.md)
- Set up a plugin manager and start customizing your Neovim experience

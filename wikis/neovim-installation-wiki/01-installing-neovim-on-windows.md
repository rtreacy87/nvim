# Installing Neovim on Windows

This guide covers the various methods to install Neovim on Windows, from package managers to manual installation.

## Prerequisites

Before installing Neovim on Windows, ensure you have:

- Windows 7 or newer (Windows 10/11 recommended)
- Administrator privileges (for some installation methods)
- Internet connection
- Familiarity with Command Prompt or PowerShell

## Installation Methods

### Method 1: Using Chocolatey (Recommended)

[Chocolatey](https://chocolatey.org/) is a package manager for Windows that makes installing software easy.

1. **Install Chocolatey** (if not already installed):
   - Open PowerShell as Administrator
   - Run the following command:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Install Neovim**:
   - In the same PowerShell window, run:
   ```powershell
   choco install neovim
   ```

3. **Verify installation**:
   ```powershell
   nvim --version
   ```

### Method 2: Using Scoop

[Scoop](https://scoop.sh/) is another package manager for Windows that focuses on command-line tools.

1. **Install Scoop** (if not already installed):
   - Open PowerShell
   - Run:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   irm get.scoop.sh | iex
   ```

2. **Install Neovim**:
   ```powershell
   scoop install neovim
   ```

3. **Verify installation**:
   ```powershell
   nvim --version
   ```

### Method 3: Pre-built Binaries

If you prefer not to use a package manager, you can download pre-built binaries directly.

1. **Download the latest release**:
   - Visit the [Neovim Releases page](https://github.com/neovim/neovim/releases)
   - Download the latest `nvim-win64.zip` (for 64-bit Windows) or `nvim-win32.zip` (for 32-bit Windows)

2. **Extract the archive**:
   - Right-click the downloaded ZIP file and select "Extract All..."
   - Choose a destination folder (e.g., `C:\Program Files\Neovim`)

3. **Add to PATH**:
   - Open the Start menu and search for "Environment Variables"
   - Click "Edit the system environment variables"
   - Click the "Environment Variables" button
   - Under "System variables", find the "Path" variable, select it, and click "Edit"
   - Click "New" and add the path to the `bin` directory (e.g., `C:\Program Files\Neovim\bin`)
   - Click "OK" on all dialogs to save changes

4. **Verify installation**:
   - Open a new Command Prompt or PowerShell window
   - Run:
   ```
   nvim --version
   ```

### Method 4: Windows Package Manager (winget)

Windows 10 and 11 users can use the built-in Windows Package Manager.

1. **Install Neovim**:
   - Open PowerShell or Command Prompt
   - Run:
   ```
   winget install Neovim.Neovim
   ```

2. **Verify installation**:
   ```
   nvim --version
   ```

## Post-Installation Setup

### Setting Up Environment Variables

For optimal functionality, consider setting these environment variables:

1. **XDG Base Directory Specification**:
   - Open PowerShell as Administrator
   - Run:
   ```powershell
   [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$env:USERPROFILE\.config", "User")
   [Environment]::SetEnvironmentVariable("XDG_DATA_HOME", "$env:USERPROFILE\.local\share", "User")
   [Environment]::SetEnvironmentVariable("XDG_STATE_HOME", "$env:USERPROFILE\.local\state", "User")
   ```

2. **Create configuration directories**:
   ```powershell
   mkdir -p $env:USERPROFILE\.config\nvim
   mkdir -p $env:USERPROFILE\.local\share\nvim\site
   ```

### Installing a Terminal Emulator

For the best Neovim experience on Windows, consider using one of these terminal emulators:

1. **Windows Terminal** (Recommended):
   - Install from the [Microsoft Store](https://aka.ms/terminal)
   - Or using Chocolatey: `choco install microsoft-windows-terminal`

2. **Alacritty**:
   - Install using Chocolatey: `choco install alacritty`
   - Or using Scoop: `scoop install alacritty`

### Installing a Nerd Font

For proper icon support in Neovim plugins:

1. **Using Chocolatey**:
   ```powershell
   choco install nerd-fonts-hack
   ```

2. **Using Scoop**:
   ```powershell
   scoop bucket add nerd-fonts
   scoop install Hack-NF
   ```

3. **Manual installation**:
   - Download from [Nerd Fonts](https://www.nerdfonts.com/)
   - Install by right-clicking the font files and selecting "Install"

## Troubleshooting Common Issues

### Neovim Not Found After Installation

If `nvim` command is not recognized after installation:

1. **Verify PATH**:
   - Open PowerShell and run:
   ```powershell
   $env:Path -split ';'
   ```
   - Check if the Neovim bin directory is listed

2. **Restart Terminal**:
   - Close and reopen your terminal to refresh environment variables

3. **Manually add to PATH** if needed:
   ```powershell
   $neovimPath = "C:\path\to\neovim\bin"
   $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
   [Environment]::SetEnvironmentVariable("Path", "$currentPath;$neovimPath", "User")
   ```

### DLL Missing Errors

If you encounter DLL missing errors:

1. **Install Visual C++ Redistributable**:
   - Download and install the [latest Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

2. **Verify Windows Updates**:
   - Ensure Windows is up to date with the latest updates

### Clipboard Integration Issues

If clipboard integration isn't working:

1. **Check clipboard provider**:
   - Inside Neovim, run:
   ```
   :checkhealth provider
   ```

2. **Install win32yank**:
   ```powershell
   scoop install win32yank
   ```

## Next Steps

Now that you have Neovim installed on Windows, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore [Building Neovim from Source on Windows](02-building-neovim-from-source-on-windows.md) for the latest features
- Set up [Neovim on WSL](03-neovim-on-wsl.md) for a Linux-like development environment

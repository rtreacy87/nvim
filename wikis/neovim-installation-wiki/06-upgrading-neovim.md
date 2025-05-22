# Upgrading Neovim

This guide covers how to upgrade Neovim across different platforms, manage breaking changes, and ensure plugin compatibility.

## When to Upgrade

Consider upgrading Neovim when:

- Security updates are released
- New features you need become available
- Bug fixes address issues you're experiencing
- Plugins you want to use require a newer version

## Before Upgrading

Before upgrading Neovim, take these precautions:

1. **Backup your configuration**:
   ```bash
   # On Unix-like systems (Linux/macOS)
   cp -r ~/.config/nvim ~/.config/nvim.backup
   cp -r ~/.local/share/nvim ~/.local/share/nvim.backup

   # On Windows (PowerShell)
   Copy-Item -Recurse $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.backup
   Copy-Item -Recurse $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.backup
   ```

2. **Check plugin compatibility**:
   - Review the release notes for the new Neovim version
   - Check if your critical plugins support the new version
   - Look for breaking changes in the Neovim API

3. **Check for Lua API changes** if you use Lua for configuration:
   - Review the [Neovim changelog](https://github.com/neovim/neovim/blob/master/CHANGELOG.md)
   - Pay attention to deprecated functions or changed behavior

## Upgrading on Different Platforms

### Upgrading on Windows

#### Using Chocolatey

```powershell
choco upgrade neovim
```

#### Using Scoop

```powershell
scoop update neovim
```

#### Using winget

```powershell
winget upgrade Neovim.Neovim
```

#### Manual Upgrade (Pre-built Binaries)

1. **Download** the latest release from [Neovim Releases](https://github.com/neovim/neovim/releases)
2. **Extract** the ZIP file to replace your existing installation
3. **Verify** the installation:
   ```powershell
   nvim --version
   ```

### Upgrading on macOS

#### Using Homebrew

```bash
brew update
brew upgrade neovim
```

#### Using MacPorts

```bash
sudo port selfupdate
sudo port upgrade neovim
```

#### Manual Upgrade (Pre-built Binaries)

```bash
# Download and extract
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-macos.tar.gz
tar xzf nvim-macos.tar.gz

# Replace existing installation
sudo rm -rf /opt/nvim-macos
sudo mv nvim-macos /opt/
```

### Upgrading on Linux

#### Ubuntu/Debian (PPA)

```bash
sudo apt update
sudo apt upgrade neovim
```

#### Fedora

```bash
sudo dnf upgrade neovim
```

#### Arch Linux

```bash
sudo pacman -Syu neovim
```

#### AppImage

```bash
# Download the latest AppImage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

# Replace the existing AppImage
sudo mv nvim.appimage /opt/nvim/nvim
```

#### Snap

```bash
sudo snap refresh nvim
```

#### Flatpak

```bash
flatpak update io.neovim.nvim
```

### Upgrading from Source

If you installed Neovim from source:

```bash
# Navigate to your Neovim source directory
cd ~/neovim  # or wherever you cloned it

# Pull the latest changes
git pull

# Checkout the desired version
git checkout stable  # or a specific version like v0.9.0, or master for development

# Clean build artifacts (optional but recommended)
make clean

# Rebuild and install
make CMAKE_BUILD_TYPE=Release
sudo make install
```

## Managing Breaking Changes

### Identifying Breaking Changes

1. **Check the official changelog**:
   - Visit [Neovim Releases](https://github.com/neovim/neovim/releases)
   - Read the release notes for breaking changes

2. **Run the health check**:
   ```
   :checkhealth
   ```

3. **Check for deprecated features**:
   ```
   :messages
   ```
   Look for warnings about deprecated features.

### Common Breaking Changes and Solutions

#### Lua API Changes

**Issue**: Functions moved or renamed in the Lua API.

**Solution**: Update your configuration to use the new function names:

```lua
-- Example: vim.api.nvim_command was deprecated in favor of vim.cmd
-- Old code
vim.api.nvim_command('set number')

-- New code
vim.cmd('set number')
```

#### Plugin Compatibility

**Issue**: Plugins may not work with the new Neovim version.

**Solution**:
1. Update all plugins:
   ```
   # For vim-plug
   :PlugUpdate

   # For packer
   :PackerSync

   # For lazy.nvim
   :Lazy sync
   ```

2. Check plugin repositories for compatibility information
3. Temporarily disable problematic plugins until they're updated

#### Configuration Syntax Changes

**Issue**: Configuration syntax or options may change between versions.

**Solution**:
1. Review error messages when starting Neovim
2. Update configuration based on error messages
3. Consult the `:help` documentation for new options

## Plugin Compatibility

### Checking Plugin Compatibility

1. **Run plugin health checks**:
   ```
   :checkhealth
   ```

2. **Check plugin repositories**:
   - Look for compatibility information in the README
   - Check issues related to the Neovim version you're upgrading to

3. **Test in a clean environment**:
   ```bash
   # Start Neovim with minimal configuration
   nvim --clean
   ```

### Updating Plugins

#### Using vim-plug

```vim
:PlugUpdate
```

#### Using packer.nvim

```vim
:PackerSync
```

#### Using lazy.nvim

```vim
:Lazy sync
```

### Handling Incompatible Plugins

If a plugin is incompatible with your new Neovim version:

1. **Check for forks or alternatives**:
   - Search GitHub for maintained forks
   - Look for alternative plugins with similar functionality

2. **Pin Neovim to a compatible version** (temporary solution):
   - Downgrade to the last working version
   - Wait for plugin updates

3. **Disable the plugin temporarily**:
   ```lua
   -- In your init.lua, comment out the problematic plugin
   -- require('packer').startup(function(use)
   --   use 'problematic/plugin'
   -- end)
   ```

## Rollback Strategies

### Rollback on Windows

#### Using Chocolatey

```powershell
choco uninstall neovim
choco install neovim --version=x.y.z
```

#### Using Scoop

```powershell
scoop uninstall neovim
scoop install neovim@x.y.z
```

#### Manual Rollback

1. **Download** the previous version from [Neovim Releases](https://github.com/neovim/neovim/releases)
2. **Replace** your current installation

### Rollback on macOS

#### Using Homebrew

```bash
# List available versions
brew info neovim

# Install a specific version
brew uninstall neovim
brew install neovim@x.y.z
```

#### Manual Rollback

Restore from your backup or download a specific version.

### Rollback on Linux

#### Using AppImage

1. **Download** a specific version from [Neovim Releases](https://github.com/neovim/neovim/releases)
2. **Replace** your current AppImage

#### From Source

```bash
cd ~/neovim
git checkout v0.x.y  # Specific version
make clean
make CMAKE_BUILD_TYPE=Release
sudo make install
```

### Restoring Configuration Backup

If you need to restore your configuration backup:

```bash
# On Unix-like systems (Linux/macOS)
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
cp -r ~/.config/nvim.backup ~/.config/nvim
cp -r ~/.local/share/nvim.backup ~/.local/share/nvim

# On Windows (PowerShell)
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim
Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim-data
Copy-Item -Recurse $env:LOCALAPPDATA\nvim.backup $env:LOCALAPPDATA\nvim
Copy-Item -Recurse $env:LOCALAPPDATA\nvim-data.backup $env:LOCALAPPDATA\nvim-data
```

## Best Practices for Smooth Upgrades

1. **Stay informed**:
   - Follow [Neovim on GitHub](https://github.com/neovim/neovim)
   - Join the [Neovim Matrix chat](https://matrix.to/#/#neovim:matrix.org)
   - Subscribe to the [Neovim subreddit](https://www.reddit.com/r/neovim/)

2. **Use version control** for your configuration:
   ```bash
   # Initialize a Git repository for your config
   cd ~/.config/nvim
   git init
   git add .
   git commit -m "Initial configuration"
   ```

3. **Document your configuration**:
   - Add comments explaining why certain settings are used
   - Group related settings together
   - Use modular configuration files

4. **Test upgrades in a separate environment**:
   ```bash
   # Create a test environment
   mkdir -p ~/nvim-test/config
   XDG_CONFIG_HOME=~/nvim-test/config XDG_DATA_HOME=~/nvim-test/data nvim
   ```

5. **Gradually adopt new features**:
   - Don't rewrite your entire configuration at once
   - Incrementally update and test changes

## Next Steps

Now that you know how to upgrade Neovim, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore the latest features in your newly upgraded Neovim
- Update your plugins and configuration to take advantage of new capabilities

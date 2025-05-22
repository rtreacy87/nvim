# Neovim Installation Guide

Welcome to the Neovim Installation Guide! This series of wikis will help you install, build, configure, and upgrade Neovim on various platforms.

## About Neovim

[Neovim](https://neovim.io/) is a hyperextensible text editor built for efficiency. It's a fork of Vim that focuses on extensibility and usability, making it easier to configure and extend compared to traditional Vim.

## Installation Guides

This series consists of seven guides covering installation and configuration across all major platforms:

1. [**Installing Neovim on Windows**](01-installing-neovim-on-windows.md)
   - Package managers (Chocolatey, Scoop)
   - Pre-built binaries
   - Setting up environment variables
   - Common installation issues

2. [**Building Neovim from Source on Windows**](02-building-neovim-from-source-on-windows.md)
   - Required dependencies
   - Setting up build environment
   - Compilation process
   - Installation from source
   - Troubleshooting build issues

3. [**Neovim on WSL (Windows Subsystem for Linux)**](03-neovim-on-wsl.md)
   - Setting up WSL
   - Installing Neovim in WSL
   - Clipboard integration
   - GUI options with WSL
   - Windows-WSL interoperability

4. [**Installing Neovim on macOS**](04-installing-neovim-on-macos.md)
   - Using Homebrew
   - Using MacPorts
   - Pre-built binaries
   - Building from source on macOS
   - macOS-specific considerations

5. [**Installing Neovim on Linux**](05-installing-neovim-on-linux.md)
   - Distribution-specific package managers
   - AppImage installation
   - Snap and Flatpak options
   - Building from source on Linux
   - Common Linux issues

6. [**Upgrading Neovim**](06-upgrading-neovim.md)
   - Upgrading on different platforms
   - Managing breaking changes
   - Plugin compatibility
   - Configuration adjustments
   - Rollback strategies

7. [**Neovim Configuration Locations**](07-neovim-configuration-locations.md)
   - Configuration directory structure
   - Platform-specific paths
   - init.lua vs init.vim
   - Plugin directories
   - Migration from Vim

## Who These Guides Are For

These guides are designed for:

- New users installing Neovim for the first time
- Existing users wanting to upgrade or reinstall
- Users switching platforms
- Those who want to build Neovim from source for the latest features
- Anyone looking to properly set up their Neovim configuration

The guides assume basic familiarity with command-line interfaces but explain concepts clearly for those with limited experience.

## Getting Started

Before diving into Neovim configuration and plugins, you should first install Neovim using one of the methods described in these guides. Begin with the installation guide for your platform:

- Windows: [Installing Neovim on Windows](01-installing-neovim-on-windows.md)
- macOS: [Installing Neovim on macOS](04-installing-neovim-on-macos.md)
- Linux: [Installing Neovim on Linux](05-installing-neovim-on-linux.md)
- WSL: [Neovim on WSL](03-neovim-on-wsl.md)

After installation, check out [Neovim Configuration Locations](07-neovim-configuration-locations.md) to understand where and how to set up your configuration.

## Additional Resources

- [Official Neovim Website](https://neovim.io/)
- [Neovim GitHub Repository](https://github.com/neovim/neovim)
- [Neovim Documentation](https://neovim.io/doc/)
- [Neovim Discourse Forum](https://neovim.discourse.group/)
- [Neovim Matrix Chat](https://matrix.to/#/#neovim:matrix.org)

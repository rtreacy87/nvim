# Telescope in Neovim - Wiki Series

Welcome to the Telescope in Neovim wiki series! This collection of guides will help you understand, set up, and effectively use Telescope to enhance your Neovim experience.

## About Telescope

Telescope is a highly extendable fuzzy finder for Neovim. It helps you search, filter, find, and pick items across various sources like files, buffers, git commits, and much more. With its powerful interface and extensibility, Telescope transforms how you navigate and interact with your code.

While Telescope provides an excellent interactive interface, it has some limitations when working with macros and automation. This wiki series also covers command mode file operations that complement Telescope, providing reliable alternatives for scenarios where Telescope's interactive nature might not be ideal.

## Wiki Guides

This series consists of ten guides that will take you from basic concepts to advanced usage:

1. [**Introduction to Telescope**](01-introduction-to-telescope.md)
   - What is Telescope and why use it?
   - Core concepts: pickers, sorters, and previewers
   - How Telescope differs from other fuzzy finders
   - Benefits for different workflows

2. [**Installing and Configuring Telescope**](02-installing-and-configuring-telescope.md)
   - Installation methods (using package managers)
   - Basic configuration in your Neovim setup
   - Required dependencies (plenary.nvim, etc.)
   - Optional dependencies (fzf-native, ui-select, etc.)

3. [**Basic Telescope Usage**](03-basic-telescope-usage.md)
   - Common built-in pickers (find_files, live_grep, etc.)
   - Default keymaps and navigation
   - Searching and filtering techniques
   - Working with results

4. [**Customizing Telescope**](04-customizing-telescope.md)
   - Configuring appearance and behavior
   - Creating custom themes
   - Setting up custom keymaps
   - Adjusting sorting and matching algorithms

5. [**Advanced Telescope Features**](05-advanced-telescope-features.md)
   - Using extensions (fzf-native, ui-select, etc.)
   - Creating custom pickers
   - Integration with other plugins
   - Performance optimization

6. [**Telescope for Project Management**](06-telescope-for-project-management.md)
   - Navigating codebases efficiently
   - Managing buffers and windows
   - Git integration
   - Project-specific configurations

7. [**Troubleshooting and Tips**](07-troubleshooting-and-tips.md)
   - Common issues and solutions
   - Performance optimization
   - Platform-specific considerations
   - Advanced usage patterns

8. [**Command Mode File Operations**](08-command-mode-file-operations.md)
   - Basic file operations in command mode
   - Using registers for path manipulation
   - Practical examples with registers
   - Integration with macros

9. [**Command Mode Workflows**](09-command-mode-workflows.md)
   - Project file structure generation
   - Batch file renaming
   - Creating file pairs (implementation and test)
   - Project navigation with bookmarks
   - Template-based file generation

10. [**Creating Custom File Commands**](10-creating-custom-file-commands.md)
    - Defining custom commands
    - Essential file operation commands
    - Advanced custom commands
    - Organizing your custom commands

## Who These Guides Are For

These guides are designed for:

- Neovim users who want to improve their navigation and search capabilities
- Developers looking for efficient ways to manage large codebases
- Anyone transitioning from other fuzzy finders or file explorers
- Users who need reliable file operations that work with macros and automation
- Developers who want to create custom file management workflows
- Both beginners and experienced Neovim users

The guides assume basic familiarity with Neovim but explain concepts clearly for those with limited experience.

## Getting Started

Begin with the first guide, [Introduction to Telescope](01-introduction-to-telescope.md), and work your way through the series in order.

## Additional Resources

- [Official Telescope Repository](https://github.com/nvim-telescope/telescope.nvim)
- [Telescope Wiki on GitHub](https://github.com/nvim-telescope/telescope.nvim/wiki)
- [Telescope Extensions](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions)

# Treesitter in Neovim - Wiki Series

Welcome to the Treesitter in Neovim wiki series! This collection of guides will help you understand, set up, and effectively use Treesitter to enhance your Neovim experience.

## About Treesitter

Treesitter is a parsing system that provides accurate syntax highlighting, indentation, and code navigation capabilities for multiple programming languages. Unlike traditional regex-based highlighting, Treesitter builds a concrete syntax tree of your code, enabling more accurate and context-aware features.

## Folding and Navigation Cheatsheet

| Category | Command | Description |
|----------|---------|-------------|
| **Folding** | `zj` | Move to the next fold |
|  | `zk` | Move to the previous fold |
|  | `zc` | Close a fold |
|  | `zo` | Open a fold |
|  | `za` | Toggle a fold |
|  | `zM` | Close all folds |
|  | `zR` | Open all folds |
| **Text Objects** | `af` | Around function (outer) |
|  | `if` | Inside function (inner) |
|  | `ac` | Around class (outer) |
|  | `ic` | Inside class (inner) |
|  | `aa` | Around parameter (outer) |
|  | `ia` | Inside parameter (inner) |
| **Navigation** | `]m` | Go to next function start |
|  | `]]` | Go to next class start |
|  | `]M` | Go to next function end |
|  | `][` | Go to next class end |
|  | `[m` | Go to previous function start |
|  | `[[` | Go to previous class start |
|  | `[M` | Go to previous function end |
|  | `[]` | Go to previous class end |

### Differences Between Inner and Outer Text Objects

- **Inner Text Objects**: Select the content within the function, class, or parameter, excluding the delimiters.
  ```python
  def example_function():
      # Using 'if' (inner function) would select only these lines
      statement1
      statement2
  ```

- **Outer Text Objects**: Select the entire function, class, or parameter, including the delimiters.
  ```python
  # Using 'af' (around function) would select this entire block
  def example_function():
      statement1
      statement2
  ```

- **Inner Parameter**: Select the content within parameter parentheses.
  ```python
  function_call(param1, param2)
  # Using 'ia' on param1 selects just "param1"
  ```

- **Outer Parameter**: Select the parameter including commas.
  ```python
  function_call(param1, param2)
  # Using 'aa' on param1 selects "param1,"
  ```

- **Inner Class**: Select the content within the class, excluding the class definition.
  ```python
  class ExampleClass:
      # Using 'ic' (inner class) would select only these lines
      def __init__(self):
          self.value = 10
      
      def method(self):
          return self.value
  ```

- **Outer Class**: Select the entire class, including the class definition.
  ```python
  # Using 'ac' (around class) would select this entire block
  class ExampleClass:
      def __init__(self):
          self.value = 10
      
      def method(self):
        return self.value
  ```

## Wiki Guides

This series consists of eight guides that will take you from basic concepts to advanced usage:

1. [**Introduction to Treesitter**](01-introduction-to-treesitter.md)
   - What is Treesitter and why use it?
   - How Treesitter differs from traditional syntax highlighting
   - Benefits for different programming languages
   - Understanding parsers and syntax trees

2. [**Installing and Configuring Treesitter**](02-installing-and-configuring-treesitter.md)
   - Installation methods
   - Basic configuration in your Neovim setup
   - Installing language parsers
   - Configuring auto-installation

3. [**Syntax Highlighting with Treesitter**](03-syntax-highlighting-with-treesitter.md)
   - Enabling Treesitter highlighting
   - Customizing highlight groups
   - Language-specific settings
   - Troubleshooting common highlighting issues

4. [**Code Navigation with Treesitter**](04-code-navigation-with-treesitter.md)
   - Navigating code structure
   - Using Treesitter for folding
   - Jumping between functions, classes, and blocks
   - Visualizing code structure

5. [**Treesitter Text Objects**](05-treesitter-text-objects.md)
   - Understanding Treesitter text objects
   - Selecting functions, classes, and parameters
   - Creating custom text objects
   - Integrating with other plugins

6. [**Advanced Treesitter Modules**](06-advanced-treesitter-modules.md)
   - Incremental selection
   - Treesitter context
   - Playground for debugging
   - Integration with LSP
   - Treesitter queries

7. [**Troubleshooting and Optimization**](07-troubleshooting-and-optimization.md)
   - Common issues and solutions
   - Performance optimization
   - Updating parsers
   - Compatibility with other plugins

8. [**Windows-Specific Treesitter Issues**](08-windows-specific-treesitter-issues.md)
   - Compiler setup on Windows
   - Environment and path challenges
   - Parser-specific Windows issues
   - Windows-optimized configuration

## Who These Guides Are For

These guides are designed for:

- Neovim users who want to improve their editing experience
- Developers looking for better syntax highlighting and code navigation
- Anyone transitioning from traditional regex-based highlighting
- Both beginners and experienced Neovim users

The guides assume basic familiarity with Neovim but explain concepts clearly for those with limited coding experience.

## Getting Started

Begin with the first guide, [Introduction to Treesitter](01-introduction-to-treesitter.md), and work your way through the series in order.

## Additional Resources

- [Official Treesitter Documentation](https://tree-sitter.github.io/tree-sitter/)
- [Neovim Treesitter Plugin Repository](https://github.com/nvim-treesitter/nvim-treesitter)
- [Neovim Documentation on Treesitter](https://neovim.io/doc/user/treesitter.html)

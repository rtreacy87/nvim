# Setting Up Augment Code in Your Neovim Configuration

This guide will walk you through installing and configuring Augment Code for Neovim. We'll keep things simple and explain each step clearly.

## Installation Methods

You have several options for installing the Augment Code plugin. Choose the method that works best for your setup:

### Option 1: Using Lazy.nvim (Recommended for Neovim)

If you're already using the Lazy.nvim plugin manager (which you are, based on your configuration), this is the easiest method:

1. Open your Neovim configuration file:
   ```bash
   nvim ~/.config/nvim/init.lua
   ```
   
2. Create a new file in your plugins directory:
   ```bash
   nvim ~/.config/nvim/lua/plugins/augment.lua
   ```
   
   And add the following content:
   ```lua
   return {
     'augmentcode/augment.vim'
   }
   ```

3. Save the file and exit (`:wq`)

4. Restart Neovim and run `:Lazy sync` to install the plugin

### Option 2: Manual Installation

If you prefer to install manually:

1. Close Neovim if it's open

2. Open a terminal and run:
   ```bash
   git clone https://github.com/augmentcode/augment.vim.git ~/.config/nvim/pack/augment/start/augment.vim
   ```

3. Start Neovim, and the plugin should be automatically loaded

## Basic Configuration

After installation, you need to configure the plugin to work with your codebase:

### Setting Up Workspace Folders

Workspace folders tell Augment Code which parts of your codebase to analyze. This is crucial for getting relevant suggestions.

#### Option 1: Default Workspace in `init.lua`

Add this to your `init.lua` file **before** the Lazy.nvim setup section:

```lua
-- Set Augment Code workspace folders
vim.g.augment_workspace_folders = {'/path/to/your/project'}
```

#### Option 2: Prompt for Workspace on Startup

If you frequently switch between projects, you can set up Augment to prompt you for a workspace folder on startup:

```lua
-- In lua/plugins/augment.lua
return {
  'augmentcode/augment.vim',
  config = function()
    -- Function to set workspace folder and reload Augment
    local function set_workspace_folder(path)
      vim.g.augment_workspace_folders = {path}
      vim.cmd('Augment reload')
      print("Augment workspace set to: " .. path)
    end
    
    -- Function to validate directory exists
    local function is_valid_directory(path)
      return path and path ~= '' and vim.fn.isdirectory(path) == 1
    end
    
    -- Function to prompt for workspace path
    local function prompt_for_workspace()
      local path = vim.fn.input({
        prompt = 'Enter workspace folder path: ',
        default = vim.fn.getcwd(),
        completion = 'dir'
      })
      
      if is_valid_directory(path) then
        set_workspace_folder(path)
        return true
      elseif path and path ~= '' then
        print("Error: Directory '" .. path .. "' does not exist.")
        return false
      end
      return false
    end
    
    -- Function to handle workspace initialization
    local function initialize_workspace()
      if not vim.g.augment_workspace_folders or #vim.g.augment_workspace_folders == 0 then
        vim.defer_fn(function()
          if not prompt_for_workspace() then
            -- Try again after a short delay
            vim.defer_fn(initialize_workspace, 100)
          end
        end, 100)
      end
    end
    
    -- Initialize workspace on startup
    initialize_workspace()
    
    -- Set up project switching function
    _G.SwitchAugmentProject = function(project_path)
      if is_valid_directory(project_path) then
        set_workspace_folder(project_path)
      else
        print("Error: Directory '" .. project_path .. "' does not exist.")
      end
    end
    
    -- Create a command to easily call this function
    vim.api.nvim_create_user_command('AugmentProject', 
      function(opts) _G.SwitchAugmentProject(opts.args) end, 
      {nargs = 1, complete = 'dir'})
  end
}
```

**Function-by-function explanation:**

**1. `set_workspace_folder(path)`**
- Takes a directory path as input
- Sets it as the Augment workspace folder
- Reloads Augment to apply the change
- Shows a confirmation message

**Purpose:** Centralizes the workspace folder setting logic in one place.

**2. `is_valid_directory(path)`**
- Checks if a path is not empty and exists as a directory
- Returns true or false

**Purpose:** Provides a clean way to validate directory paths.

**3. `prompt_for_workspace()`**
- Shows a prompt for entering a workspace path
- Uses directory auto-completion
- Validates the entered path
- Sets the workspace if valid
- Returns true if successful, false otherwise

**Purpose:** Handles the user interaction for selecting a workspace.

**4. `initialize_workspace()`**
- Checks if workspace folders are already set
- If not, prompts for a workspace path
- Retries if the user enters an invalid path

**Purpose:** Manages the workspace initialization flow.

**5. `SwitchAugmentProject(project_path)`**
- Takes a project path as input
- Validates the path
- Sets it as the workspace if valid
- Shows an error if invalid

**Purpose:** Provides a way to switch projects with validation.

This approach follows clean code principles by:
- Breaking down complex logic into smaller, focused functions
- Giving each function a single responsibility
- Reducing nesting depth
- Making the code more readable and maintainable

With this setup, you'll be prompted to select a workspace folder when you start Neovim, and you can switch projects at any time using the `:AugmentProject` command.

You can add multiple folders if needed:
```lua
vim.g.augment_workspace_folders = {
  '/path/to/main/project',
  '/path/to/another/related/project'
}
```

### Switching Between Projects

If you work on multiple projects and need to switch between them frequently, you can add this to your `augment.lua` file:

1. **Update your `augment.lua`** in the plugins directory:
   ```lua
   -- Define the project switching function
   local function setup_project_switching()
     -- Create the project switching function
     _G.SwitchAugmentProject = function(project_path)
       vim.g.augment_workspace_folders = {project_path}
       vim.cmd('Augment reload')
       print("Augment workspace switched to: " .. project_path)
     end
     
     -- Create a command to easily call this function
     vim.api.nvim_create_user_command('AugmentProject', 
       function(opts) _G.SwitchAugmentProject(opts.args) end, 
       {nargs = 1, complete = 'dir'})
   end
   
   -- Return the plugin configuration with the setup
   return {
     'augmentcode/augment.vim',
     config = function()
       setup_project_switching()
     end
   }
   ```

2. **Use the command** to switch projects:
   ```
   :AugmentProject /path/to/new/project
   ```

3. **Check indexing status** after switching:
   ```
   :Augment status
   ```

This approach keeps all Augment-related configuration in one file and ensures the command is created after the plugin is loaded.

### Step 2: Sign In to Augment Code

After installing and configuring the plugin:

1. Open Neovim
2. Run the command: `:Augment signin`
3. Follow the instructions in the browser that opens
4. After signing in, you'll be redirected back to Neovim

## Integrating with Your Existing Configuration

### Where to Place Configuration

For the best results:

1. Place the `vim.g.augment_workspace_folders` setting **before** loading any plugins
2. Make sure it's near the top of your `init.lua` file, before the `require('lazy').setup` call

### Example Configuration

Here's how your configuration might look:

```lua
-- Basic settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Augment Code configuration
vim.g.augment_workspace_folders = {'/path/to/your/project'}

-- Load plugins with Lazy
require('lazy').setup({
  -- Your existing plugins
  { 'augmentcode/augment.vim' },
  -- Other plugins
})
```

## Verifying Installation

To check if Augment Code is properly installed and configured:

1. Open Neovim
2. Run the command: `:Augment status`

You should see information about your connection status and workspace indexing progress.

## Troubleshooting Common Installation Issues

### Plugin Not Loading

If the plugin doesn't seem to be loading:

1. Check if it's installed correctly:
   - For Lazy.nvim: Run `:Lazy` and look for `augment.vim` in the list
   - For manual installation: Check if the files exist in the correct directory

2. Make sure you have the required dependencies:
   - Run `node --version` to verify Node.js is installed and is version 22.0.0 or newer

### Sign-In Issues

If you have trouble signing in:

1. Make sure you have an active internet connection
2. Try running `:Augment signin` again
3. If a browser doesn't open automatically, check the URL in the Neovim command output and open it manually

### Workspace Folders Not Recognized

If your workspace folders aren't being recognized:

1. Make sure the paths are correct and accessible
2. Check that you've set `vim.g.augment_workspace_folders` before loading the plugin
3. Restart Neovim after making changes

## Next Steps

Now that you've installed and configured Augment Code, proceed to the next guide to learn how to optimize your workspace context for the best results.

Continue to [Maximizing Augment Code's Understanding of Your Codebase](03-configuring-workspace-context.md).












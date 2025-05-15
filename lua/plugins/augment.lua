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
# CodeCompanion Setup Guide - Part 5: Troubleshooting Common Issues

## Overview

This comprehensive troubleshooting guide addresses the most common issues you might encounter with CodeCompanion and Ollama integration. Each issue includes detailed diagnostics, step-by-step solutions, and prevention tips.

## Issue 1: YAML Parser Missing (Your Current Issue)

### Problem
```
❌ ERROR yaml parser not found
```

### Diagnosis
```vim
:TSInstallInfo yaml
```

**If you see:**
```
yaml: [✗] not installed
```

### Solution Steps

**Method 1: Direct Installation**
```vim
:TSInstall yaml
```

**Method 2: If Method 1 Fails**
```vim
:TSUpdate
:TSInstall! yaml
```

**Method 3: Manual Installation**
```bash
# From terminal
cd ~/.local/share/nvim/site/pack/packer/start/nvim-treesitter
git pull
nvim -c "TSInstall yaml" -c "qa"
```

**Method 4: Complete Reset**
```vim
:TSUninstall yaml
:TSUpdate
:TSInstall yaml
```

### Verification
```vim
:TSInstallInfo yaml
:checkhealth codecompanion
```

**Expected output:**
```
yaml: [✓] installed
```

## Issue 2: Ollama Connection Problems

### Problem
CodeCompanion can't connect to Ollama, showing timeout or connection errors.

### Diagnosis Commands

**Check Ollama service:**
```bash
sudo systemctl status ollama
```

**Test API endpoint:**
```bash
curl -X GET http://localhost:11434/api/tags
```

**Check if port is open:**
```bash
netstat -tlnp | grep 11434
```

### Solutions

**Solution 1: Start/Restart Ollama**
```bash
sudo systemctl start ollama
sudo systemctl enable ollama
```

**Solution 2: Check Ollama logs**
```bash
sudo journalctl -u ollama -f
```

**Solution 3: Manual Ollama start (for debugging)**
```bash
# Stop service
sudo systemctl stop ollama

# Start manually to see output
ollama serve
```

**Solution 4: Port configuration**
```bash
# Check if another service is using port 11434
sudo lsof -i :11434

# If needed, configure different port
export OLLAMA_HOST=0.0.0.0:8080
ollama serve
```

### CodeCompanion Configuration Fix
If using a different port, update your config:

```lua
adapters = {
  ollama = function()
    return require('codecompanion.adapters').extend('ollama', {
      env = {
        url = 'http://localhost:8080', -- Change port here
      },
    })
  end,
},
```

## Issue 3: No Models Available

### Problem
```
Error: no models found
```

### Diagnosis
```bash
ollama list
```

**If empty:**
```
NAME    ID    SIZE    MODIFIED
```

### Solution
```bash
# Download a model
ollama pull codellama:7b

# Verify download
ollama list

# Test the model
ollama run codellama:7b "Hello world"
```

### Large Model Download Issues

**Problem:** Download interrupted or failed

**Solution:**
```bash
# Clear incomplete downloads
rm -rf ~/.ollama/models/blobs/sha256-*

# Re-download
ollama pull codellama:7b

# Monitor download progress
watch -n 1 'ollama list'
```

## Issue 4: Performance Issues

### Problem
CodeCompanion responses are very slow or cause system freezing.

### Diagnosis

**Check system resources:**
```bash
# CPU and memory usage
htop

# Ollama process specifically
ps aux | grep ollama

# Memory usage
free -h
```

### Solutions

**Solution 1: Use smaller models**
```bash
# Remove large model
ollama rm codellama:13b

# Use smaller model
ollama pull codellama:7b
```

**Solution 2: Limit Ollama memory usage**
```bash
# Edit service file
sudo systemctl edit ollama

# Add these lines:
[Service]
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_QUEUE=1"

# Restart service
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

**Solution 3: Optimize CodeCompanion settings**
```lua
-- Add to your config
opts = {
  log_level = 'ERROR',
  max_messages = 20,        -- Reduce message history
  send_code = false,        -- Don't send code automatically
  auto_save_session = false, -- Disable auto-save
},
```

## Issue 5: Tree-sitter Related Errors

### Problem
Various Tree-sitter parser errors or syntax highlighting issues.

### Diagnosis
```vim
:checkhealth nvim-treesitter
```

### Solutions

**Solution 1: Update all parsers**
```vim
:TSUpdate
```

**Solution 2: Reinstall problematic parsers**
```vim
:TSUninstall markdown yaml
:TSInstall markdown yaml
```

**Solution 3: Clear Tree-sitter cache**
```bash
# Remove cache directory
rm -rf ~/.cache/nvim/treesitter

# Restart Neovim and reinstall
nvim -c "TSInstall markdown yaml" -c "qa"
```

**Solution 4: Compiler issues (Linux)**
```bash
# Install build tools
sudo apt update
sudo apt install build-essential

# For Ubuntu/Debian
sudo apt install gcc g++ make

# Reinstall parsers
nvim -c "TSInstall! markdown yaml" -c "qa"
```

## Issue 6: Plugin Loading Errors

### Problem
CodeCompanion plugin fails to load or shows Lua errors.

### Diagnosis
```vim
:messages
:checkhealth lazy
```

### Solutions

**Solution 1: Plugin manager sync**
```vim
:Lazy sync
:Lazy clean
:Lazy update
```

**Solution 2: Clear plugin cache**
```bash
# Remove Lazy.nvim cache
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.cache/nvim

# Restart and reinstall
nvim -c "Lazy sync" -c "qa"
```

**Solution 3: Configuration syntax check**
```lua
-- Test your config file for syntax errors
-- Add this temporarily to your config:
local ok, err = pcall(function()
  require('codecompanion').setup({
    -- Your config here
  })
end)

if not ok then
  print('CodeCompanion config error:', err)
end
```

## Issue 7: Authentication/Permission Issues

### Problem
Permission denied errors when accessing Ollama or plugin directories.

### Solutions

**Solution 1: Fix Ollama permissions**
```bash
# Fix Ollama service permissions
sudo chown -R ollama:ollama /usr/share/ollama
sudo chmod -R 755 /usr/share/ollama

# Fix user access to Ollama
sudo usermod -a -G ollama $USER

# Restart session or reboot
```

**Solution 2: Fix Neovim plugin permissions**
```bash
# Fix plugin directory permissions
chmod -R 755 ~/.local/share/nvim
chmod -R 755 ~/.config/nvim
```

## Issue 8: Network/Firewall Issues

### Problem
CodeCompanion can't reach Ollama due to network restrictions.

### Diagnosis
```bash
# Test local connection
curl -v http://localhost:11434/api/tags

# Check firewall status
sudo ufw status
```

### Solutions

**Solution 1: Allow local connections**
```bash
# Allow local Ollama port
sudo ufw allow 11434/tcp

# Or disable firewall temporarily for testing
sudo ufw disable
```

**Solution 2: Test with different network interface**
```bash
# Start Ollama on all interfaces
export OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

## Issue 9: Model Context Length Issues

### Problem
"context length exceeded" errors when sending large code blocks.

### Solutions

**Solution 1: Reduce context in CodeCompanion**
```lua
-- Limit context size in your config
context = {
  surrounding_text = {
    lines_before = 5,  -- Reduce from 10
    lines_after = 5,   -- Reduce from 10
  },
},
```

**Solution 2: Use models with larger context**
```bash
# Use models with larger context windows
ollama pull llama3.1:8b  # 128k context
```

**Solution 3: Split large requests**
Instead of sending entire files, send smaller focused sections.

## Issue 10: Logging and Debugging

### Enable Debug Logging

**CodeCompanion debug logging:**
```lua
-- Add to your config
opts = {
  log_level = 'DEBUG',
  debug = true,
},
```

**View CodeCompanion logs:**
```bash
tail -f ~/.local/state/nvim/codecompanion.log
```

**Ollama debug logging:**
```bash
# Set debug environment
export OLLAMA_DEBUG=1
ollama serve

# Or check service logs
sudo journalctl -u ollama -n 100 -f
```

## Diagnostic Commands Reference

### Quick Health Check Script

Create a diagnostic script `~/check_codecompanion.sh`:

```bash
#!/bin/bash
echo "=== CodeCompanion Diagnostic Script ==="
echo

echo "1. Checking Neovim version..."
nvim --version | head -1

echo "2. Checking Ollama service..."
sudo systemctl status ollama --no-pager

echo "3. Checking Ollama models..."
ollama list

echo "4. Testing Ollama API..."
curl -s http://localhost:11434/api/tags | head -5

echo "5. Checking Tree-sitter parsers..."
nvim -c "TSInstallInfo yaml" -c "TSInstallInfo markdown" -c "qa" 2>&1 | grep -E "(yaml|markdown)"

echo "6. Checking plugin directory..."
ls -la ~/.local/share/nvim/lazy/codecompanion.nvim/ | head -5

echo "7. Checking system resources..."
free -h
echo "CPU cores: $(nproc)"

echo "=== Diagnostic Complete ==="
```

**Run the diagnostic:**
```bash
chmod +x ~/check_codecompanion.sh
~/check_codecompanion.sh
```

## Recovery Procedures

### Complete Reset Procedure

If everything is broken, here's how to start fresh:

```bash
# 1. Stop all services
sudo systemctl stop ollama

# 2. Remove configurations
rm -rf ~/.config/nvim/lua/plugins/codecompanion.lua
rm -rf ~/.local/share/nvim/lazy/codecompanion.nvim/

# 3. Clear caches
rm -rf ~/.cache/nvim/
rm -rf ~/.local/state/nvim/

# 4. Reinstall Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 5. Download model
ollama pull codellama:7b

# 6. Reinstall CodeCompanion
nvim -c "Lazy sync" -c "qa"

# 7. Test
nvim -c "checkhealth codecompanion" -c "qa"
```

## Prevention Tips

1. **Regular Updates**: Keep Ollama and plugins updated
2. **Resource Monitoring**: Monitor system resources regularly
3. **Backup Configs**: Keep backups of working configurations
4. **Test After Changes**: Always test after configuration changes
5. **Log Monitoring**: Check logs periodically for warnings

## Getting Help

If you're still having issues:

1. **Check the error logs** with the commands above
2. **Run the diagnostic script** to gather information
3. **Search existing issues** in the CodeCompanion GitHub repository
4. **Create a detailed issue** with your diagnostic output

## Next Steps

Congratulations! You now have a complete CodeCompanion setup with Ollama. You should be able to:

- Use AI assistance directly in Neovim
- Get code reviews, explanations, and suggestions
- Work with your code privately and offline
- Troubleshoot common issues independently

---

**Setup Complete!** For additional features and advanced usage, explore the [CodeCompanion documentation](https://github.com/olimorris/codecompanion.nvim) and [Ollama model library](https://ollama.com/library).
# Ollama Configuration Guide

## Overview

Ollama is configured primarily through **environment variables**, not configuration files. This approach provides flexibility and ensures settings persist across system reboots and service restarts. Environment variables control various aspects of Ollama's behavior including network binding, model storage, performance settings, and more.

## Why Environment Variables?

- **Persistent Settings**: Unlike temporary CLI flags, environment variables persist across sessions
- **Service Compatibility**: Work seamlessly with system services (systemd, launchctl, Windows services)
- **Centralized Management**: All configuration is handled through standard OS environment variable mechanisms
- **Docker-Friendly**: Easy to configure in containerized environments

## Configuration by Operating System

### Linux (systemd service)

When running Ollama as a systemd service, configure environment variables through the service file:

```bash
# Edit the Ollama service configuration
export EDITOR=nvim
sudo systemctl edit ollama.service
sudo EDITOR=nvim systemctl edit ollama.service
```

Add environment variables under the `[Service]` section:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
#Environment="OLLAMA_HOST=127.0.0.0:11434" if you only want local access
Environment="OLLAMA_MODELS=/home/ollama/.ollama/models"
Environment="OLLAMA_MAX_LOADED_MODELS=3"
Environment="OLLAMA_NUM_PARALLEL=4"
Environment="OLLAMA_KEEP_ALIVE=5m"
Environment="OLLAMA_MAX_QUEUE=512"
```

Apply the changes:

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Restart Ollama service
sudo systemctl restart ollama

# Verify service status
sudo systemctl status ollama
```

**Important for Linux**: If you change the model directory, ensure the `ollama` user has proper permissions:

```bash
sudo chown -R ollama:ollama /path/to/your/models
sudo chown -R ollama:ollama /home/ollama/.ollama/
```

### macOS

On macOS, use `launchctl` to set environment variables:

```bash
# Set individual environment variables
launchctl setenv OLLAMA_HOST "0.0.0.0:11434"
launchctl setenv OLLAMA_MODELS "$HOME/.ollama/models"
launchctl setenv OLLAMA_KEEP_ALIVE "5m"
launchctl setenv OLLAMA_MAX_LOADED_MODELS "3"
launchctl setenv OLLAMA_NUM_PARALLEL "4"

# Restart Ollama application for changes to take effect
# (Quit from menu bar, then restart)
```

Verify environment variables:

```bash
# Check if variables are set correctly
launchctl getenv OLLAMA_HOST
launchctl getenv OLLAMA_MODELS
```

### Windows

On Windows, Ollama inherits user and system environment variables:

1. **Quit Ollama**: Right-click the Ollama icon in the system tray and select "Quit"

2. **Open Environment Variables**:
   - Windows 11: Open Settings → Search for "environment variables"
   - Windows 10: Open Control Panel → Search for "environment variables"
   - Click "Edit environment variables for your account"

3. **Add/Edit Variables**: Click "New" or select existing variable to edit:
   - `OLLAMA_HOST` = `0.0.0.0:11434`
   - `OLLAMA_MODELS` = `C:\Users\%USERNAME%\.ollama\models`
   - `OLLAMA_KEEP_ALIVE` = `5m`
   - `OLLAMA_MAX_LOADED_MODELS` = `3`

4. **Apply Changes**: Click "OK" to save

5. **Restart Ollama**: Launch Ollama from the Start menu

## Essential Environment Variables

### Network Configuration

| Variable         | Description                  | Default             | Example                    |
|------------------|------------------------------|---------------------|----------------------------|
| `OLLAMA_HOST`    | Server bind address and port | `127.0.0.1:11434`   | `0.0.0.0:11434`            |
| `OLLAMA_ORIGINS` | CORS allowed origins         | `127.0.0.1,0.0.0.0` | `*` or `https://myapp.com` |

### Storage Configuration

| Variable        | Description             | Default            | Example               |
|-----------------|-------------------------|--------------------|-----------------------|
| `OLLAMA_MODELS` | Model storage directory | `~/.ollama/models` | `/data/ollama/models` |

### Performance Configuration

| Variable                   | Description                 | Default                | Notes                                   |
|----------------------------|-----------------------------|------------------------|-----------------------------------------|
| `OLLAMA_MAX_LOADED_MODELS` | Maximum concurrent models   | `3 × GPU count` or `3` | Depends on available memory             |
| `OLLAMA_NUM_PARALLEL`      | Parallel requests per model | Auto (4 or 1)          | Based on available memory               |
| `OLLAMA_MAX_QUEUE`         | Maximum queued requests     | `512`                  | Server returns 503 when exceeded        |
| `OLLAMA_KEEP_ALIVE`        | Model memory retention time | `5m`                   | `0`=immediate unload, `-1`=never unload |

### Advanced Configuration

| Variable                 | Description                         | Default | Notes                 |
|--------------------------|-------------------------------------|---------|-----------------------|
| `OLLAMA_DEBUG`           | Enable debug logging                | `false` | Set to `1` to enable  |
| `OLLAMA_FLASH_ATTENTION` | Enable Flash Attention optimization | `false` | Set to `1` to enable  |
| `OLLAMA_GPU_OVERHEAD`    | Reserved VRAM per GPU (bytes)       | `0`     | For multi-GPU setups  |
| `OLLAMA_NOHISTORY`       | Disable chat history                | `false` | Set to `1` to disable |

### Proxy Configuration

| Variable      | Description                  | Example                          |
|---------------|------------------------------|----------------------------------|
| `HTTPS_PROXY` | HTTPS proxy server           | `https://proxy.company.com:8080` |
| `NO_PROXY`    | Bypass proxy for these hosts | `localhost,127.0.0.1`            |

**Important**: Do not set `HTTP_PROXY` as it may disrupt client connections.

## Example Configurations

### High-Performance Setup
```bash
# For systems with ample RAM/VRAM
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_MAX_LOADED_MODELS="5"
export OLLAMA_NUM_PARALLEL="8"
export OLLAMA_KEEP_ALIVE="30m"
export OLLAMA_FLASH_ATTENTION="1"
```

### Resource-Constrained Setup
```bash
# For systems with limited resources
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_MAX_LOADED_MODELS="1"
export OLLAMA_NUM_PARALLEL="1"
export OLLAMA_KEEP_ALIVE="0"
```

### Development Setup
```bash
# For development with debugging
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_DEBUG="1"
export OLLAMA_KEEP_ALIVE="10m"
export OLLAMA_ORIGINS="*"
```

### Remote Access Setup
```bash
# For remote access (use with proper security)
export OLLAMA_HOST="0.0.0.0:11434"
export OLLAMA_ORIGINS="https://myapp.com,https://localhost:3000"
```

## Docker Configuration

When running Ollama in Docker, pass environment variables using the `-e` flag:

```bash
docker run -d \
  -v ollama:/root/.ollama \
  -p 11434:11434 \
  -e OLLAMA_HOST=0.0.0.0:11434 \
  -e OLLAMA_MAX_LOADED_MODELS=2 \
  -e OLLAMA_KEEP_ALIVE=10m \
  --name ollama \
  ollama/ollama
```

## Verification

### Check Running Configuration
```bash
# View Ollama process environment (Linux/macOS)
ps aux | grep ollama
cat /proc/$(pgrep ollama)/environ | tr '\0' '\n' | grep OLLAMA

# Test API endpoint
curl http://localhost:11434/api/tags
```

### Common Issues and Troubleshooting

1. **Service Won't Start**: Check systemd logs
   ```bash
   sudo journalctl -u ollama -f
   ```

2. **Models Not Found**: Verify `OLLAMA_MODELS` path and permissions
   ```bash
   ls -la $OLLAMA_MODELS
   ```

3. **Connection Refused**: Check if host binding is correct
   ```bash
   netstat -tlnp | grep 11434
   ```

4. **Memory Issues**: Adjust concurrent model limits
   ```bash
   # Reduce concurrent models if experiencing OOM
   export OLLAMA_MAX_LOADED_MODELS=1
   ```

## Security Considerations

- **Network Exposure**: Setting `OLLAMA_HOST=0.0.0.0` exposes Ollama to your network. Use firewall rules to restrict access.
- **CORS Origins**: Be specific with `OLLAMA_ORIGINS` to prevent unauthorized web access.
- **Proxy Certificates**: Ensure proxy certificates are installed as system certificates when using `HTTPS_PROXY`.

## File Locations

### Default Storage Paths
- **Linux**: `~/.ollama/models`
- **macOS**: `~/.ollama/models`  
- **Windows**: `C:\Users\%USERNAME%\.ollama\models`

### Log Locations
- **Linux**: Use `journalctl -u ollama` for systemd logs
- **macOS**: Console app or `~/Library/Logs/`
- **Windows**: `%LOCALAPPDATA%\Ollama\logs\`

## Migration from Old Instructions

If you previously created a `~/.config/ollama/config.json` file, you should:

1. Remove the JSON configuration file
2. Convert each JSON setting to the appropriate environment variable
3. Set environment variables using your OS-specific method above
4. Restart Ollama

This approach ensures compatibility with current and future versions of Ollama.

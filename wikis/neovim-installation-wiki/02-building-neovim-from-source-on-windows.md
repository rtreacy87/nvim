# Building Neovim from Source on Windows

This guide will walk you through the process of building Neovim from source on Windows. Building from source gives you access to the latest features and allows you to customize the build.

## Prerequisites

Before building Neovim from source, ensure you have:

- Windows 10 or 11 (64-bit recommended)
- Administrator privileges
- At least 5GB of free disk space
- Internet connection
- Patience (building from source takes time)

## Setting Up the Build Environment

### Method 1: Using MSVC (Visual Studio Build Tools)

This is the officially supported method for building Neovim on Windows.

1. **Install Visual Studio Build Tools**:
   - Download [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
   - During installation, select "Desktop development with C++"
   - Ensure the following components are selected:
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK
     - C++ CMake tools for Windows

2. **Install Git**:
   - Download and install [Git for Windows](https://git-scm.com/download/win)
   - During installation, select "Use Git from the Windows Command Prompt"

3. **Install CMake**:
   - Download and install [CMake](https://cmake.org/download/)
   - During installation, select "Add CMake to the system PATH"

4. **Install Ninja** (optional but recommended):
   - Using Chocolatey: `choco install ninja`
   - Or download from [Ninja-build releases](https://github.com/ninja-build/ninja/releases) and add to PATH

### Method 2: Using MSYS2/MinGW (Alternative)

This method uses the MinGW compiler through MSYS2.

1. **Install MSYS2**:
   - Download and install [MSYS2](https://www.msys2.org/)
   - Follow the installation instructions on the website

2. **Install required packages**:
   - Open MSYS2 MinGW 64-bit terminal
   - Run:
   ```bash
   pacman -Syu
   pacman -S mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja mingw-w64-x86_64-libtool mingw-w64-x86_64-gettext mingw-w64-x86_64-unibilium git
   ```

## Cloning the Neovim Repository

1. **Create a directory** for the source code:
   ```cmd
   mkdir C:\dev
   cd C:\dev
   ```

2. **Clone the repository**:
   ```cmd
   git clone https://github.com/neovim/neovim.git
   cd neovim
   ```

3. **Checkout a specific version** (optional):
   - For the latest stable release:
   ```cmd
   git checkout stable
   ```
   - For a specific version (e.g., v0.9.0):
   ```cmd
   git checkout v0.9.0
   ```
   - For the latest development version (may be unstable):
   ```cmd
   git checkout master
   ```

## Building Neovim

### Building with MSVC

1. **Open Developer Command Prompt**:
   - Search for "Developer Command Prompt for VS" in the Start menu
   - Run it as Administrator

2. **Navigate to the Neovim directory**:
   ```cmd
   cd C:\dev\neovim
   ```

3. **Build Neovim**:
   ```cmd
   mkdir build
   cd build
   cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
   ninja
   ```

4. **Install Neovim** (optional):
   ```cmd
   ninja install
   ```
   This will install Neovim to `C:\Program Files\Neovim`.

### Building with MSYS2/MinGW

1. **Open MSYS2 MinGW 64-bit terminal**

2. **Navigate to the Neovim directory**:
   ```bash
   cd /c/dev/neovim
   ```

3. **Build Neovim**:
   ```bash
   mkdir -p build
   cd build
   cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
   ninja
   ```

4. **Install Neovim** (optional):
   ```bash
   ninja install
   ```

## Running the Built Neovim

### Running Without Installing

You can run the built Neovim directly from the build directory:

```cmd
C:\dev\neovim\build\bin\nvim.exe
```

### Adding to PATH

To make the built Neovim accessible from anywhere:

1. **Open Environment Variables**:
   - Search for "Environment Variables" in the Start menu
   - Click "Edit the system environment variables"
   - Click "Environment Variables"

2. **Edit the PATH variable**:
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add `C:\dev\neovim\build\bin`
   - Click "OK" on all dialogs

3. **Verify**:
   - Open a new Command Prompt
   - Run `nvim --version`

## Troubleshooting Build Issues

### CMake Not Found

If you get an error that CMake is not found:

1. **Verify CMake installation**:
   ```cmd
   cmake --version
   ```

2. **Add CMake to PATH** if needed:
   - Find the CMake installation directory (typically `C:\Program Files\CMake\bin`)
   - Add it to your PATH as described above

### Build Fails with Missing Dependencies

If the build fails due to missing dependencies:

1. **For MSVC builds**:
   - Ensure you've installed all required components from Visual Studio Build Tools
   - Try running:
   ```cmd
   cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_BUNDLED=ON ..
   ```

2. **For MSYS2/MinGW builds**:
   - Install additional dependencies:
   ```bash
   pacman -S mingw-w64-x86_64-luajit mingw-w64-x86_64-lua mingw-w64-x86_64-luarocks
   ```

### Out of Memory Errors

If you encounter out of memory errors during the build:

1. **Limit parallel builds**:
   ```cmd
   ninja -j2
   ```
   This limits the build to 2 parallel processes.

## Updating and Rebuilding

To update your Neovim source and rebuild:

1. **Pull the latest changes**:
   ```cmd
   cd C:\dev\neovim
   git pull
   ```

2. **Clean the build directory** (optional but recommended):
   ```cmd
   cd build
   ninja clean
   ```

3. **Rebuild**:
   ```cmd
   ninja
   ```

4. **Reinstall** (if you installed previously):
   ```cmd
   ninja install
   ```

## Building with Specific Features

### Building with Python Support

To build with Python support:

1. **Install Python**:
   - Download and install [Python](https://www.python.org/downloads/windows/)
   - Ensure "Add Python to PATH" is checked during installation

2. **Build with Python support**:
   ```cmd
   cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DPYTHON3_EXECUTABLE=C:\path\to\python.exe ..
   ninja
   ```

### Building with LuaJIT

To use LuaJIT instead of Lua:

```cmd
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DPREFER_LUA=OFF ..
ninja
```

## Next Steps

Now that you've built Neovim from source on Windows, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore [Neovim on WSL](03-neovim-on-wsl.md) for a Linux-like development environment
- Check out [Upgrading Neovim](06-upgrading-neovim.md) for maintaining your build

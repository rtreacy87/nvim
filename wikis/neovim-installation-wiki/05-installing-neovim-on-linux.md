# Installing Neovim on Linux

This guide covers various methods to install Neovim on different Linux distributions, from package managers to building from source.

## Prerequisites

Before installing Neovim on Linux, ensure you have:

- A supported Linux distribution
- Internet connection
- Basic familiarity with the terminal
- Administrator/sudo privileges (for most installation methods)

## Distribution-Specific Installation

### Ubuntu/Debian

#### Using the Standard Repository

The version in the standard repository may be outdated:

```bash
sudo apt update
sudo apt install neovim
```

#### Using PPA (Recommended for Ubuntu)

For a more recent version:

1. **Add the PPA**:
   ```bash
   sudo add-apt-repository ppa:neovim-ppa/stable
   sudo apt update
   ```

2. **Install Neovim**:
   ```bash
   sudo apt install neovim
   ```

3. **For the development version** (optional):
   ```bash
   sudo add-apt-repository ppa:neovim-ppa/unstable
   sudo apt update
   sudo apt install neovim
   ```

### Fedora

Fedora's repositories usually contain a recent version of Neovim:

```bash
sudo dnf install -y neovim python3-neovim
```

### Arch Linux/Manjaro

Arch Linux and Manjaro have up-to-date versions in their repositories:

```bash
sudo pacman -S neovim
```

### CentOS/RHEL

For CentOS/RHEL 7 or 8:

1. **Enable EPEL repository**:
   ```bash
   # CentOS/RHEL 7
   sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

   # CentOS/RHEL 8
   sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
   ```

2. **Install Neovim**:
   ```bash
   # CentOS/RHEL 7
   sudo yum install -y neovim python3-neovim

   # CentOS/RHEL 8
   sudo dnf install -y neovim python3-neovim
   ```

### openSUSE

```bash
sudo zypper install neovim python3-neovim
```

### Gentoo

```bash
sudo emerge -a app-editors/neovim
```

### NixOS

```bash
nix-env -iA nixos.neovim
```

Or add to your configuration.nix:

```nix
environment.systemPackages = with pkgs; [
  neovim
];
```

## Universal Installation Methods

### AppImage (Recommended for any Linux distribution)

AppImage provides a portable version that works on most Linux distributions:

1. **Download the AppImage**:
   ```bash
   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
   ```

2. **Make it executable**:
   ```bash
   chmod u+x nvim.appimage
   ```

3. **Run it directly** or move to a directory in your PATH:
   ```bash
   # Run directly
   ./nvim.appimage

   # Or move to a directory in your PATH
   sudo mkdir -p /opt/nvim
   sudo mv nvim.appimage /opt/nvim/nvim
   sudo ln -s /opt/nvim/nvim /usr/local/bin/nvim
   ```

### Snap Package

For distributions that support Snap:

```bash
sudo snap install --beta nvim --classic
```

### Flatpak

For distributions that support Flatpak:

1. **Install Flatpak** (if not already installed):
   ```bash
   # Ubuntu/Debian
   sudo apt install flatpak

   # Fedora
   sudo dnf install flatpak

   # Arch Linux
   sudo pacman -S flatpak
   ```

2. **Add Flathub repository**:
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

3. **Install Neovim**:
   ```bash
   flatpak install flathub io.neovim.nvim
   ```

4. **Run Neovim**:
   ```bash
   flatpak run io.neovim.nvim
   ```

## Building from Source

Building from source gives you the latest features and allows for customization:

1. **Install build dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl

   # Fedora
   sudo dnf install -y ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl

   # Arch Linux
   sudo pacman -S base-devel cmake unzip ninja curl

   # CentOS/RHEL
   sudo yum -y install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/neovim/neovim.git
   cd neovim
   ```

3. **Build and install**:
   ```bash
   # For the stable version
   git checkout stable

   # Build
   make CMAKE_BUILD_TYPE=Release

   # Install
   sudo make install
   ```

4. **Verify installation**:
   ```bash
   nvim --version
   ```

## Post-Installation Setup

### Setting Up Configuration Directories

Create the necessary directories for Neovim configuration:

```bash
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site
```

### Creating a Basic Configuration

Create a basic `init.lua` file:

```bash
cat > ~/.config/nvim/init.lua << 'EOF'
-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Set leader key to space
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic keymaps
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  pattern = '*',
})
EOF
```

### Installing Dependencies for Plugin Support

#### Python Support

```bash
# Ubuntu/Debian
sudo apt install python3-pip
pip3 install pynvim

# Fedora
sudo dnf install python3-pip
pip3 install pynvim

# Arch Linux
sudo pacman -S python-pynvim
```

#### Node.js Support

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc  # or source ~/.zshrc
nvm install --lts
npm install -g neovim

# Ubuntu/Debian
sudo apt install nodejs npm
sudo npm install -g neovim

# Fedora
sudo dnf install nodejs npm
sudo npm install -g neovim

# Arch Linux
sudo pacman -S nodejs npm
sudo npm install -g neovim
```

### Installing a Terminal Emulator

For the best Neovim experience, consider using one of these terminal emulators:

1. **Alacritty**:
   ```bash
   # Ubuntu/Debian
   sudo apt install alacritty

   # Fedora
   sudo dnf install alacritty

   # Arch Linux
   sudo pacman -S alacritty
   ```

2. **Kitty**:
   ```bash
   # Ubuntu/Debian
   sudo apt install kitty

   # Fedora
   sudo dnf install kitty

   # Arch Linux
   sudo pacman -S kitty
   ```

### Installing a Nerd Font

For proper icon support in Neovim plugins:

```bash
# Create fonts directory if it doesn't exist
mkdir -p ~/.local/share/fonts

# Download and install Hack Nerd Font
curl -fLo ~/.local/share/fonts/Hack\ Regular\ Nerd\ Font\ Complete.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf

# Refresh font cache
fc-cache -fv
```

## Troubleshooting Common Issues

### Command Not Found

If `nvim` command is not recognized after installation:

1. **Check PATH**:
   ```bash
   echo $PATH
   ```

2. **Locate nvim binary**:
   ```bash
   which nvim
   ```

3. **Add to PATH if needed**:
   Add to your `~/.bashrc` or `~/.zshrc`:
   ```bash
   export PATH="/path/to/nvim/bin:$PATH"
   ```

### AppImage Issues

If the AppImage doesn't run:

1. **Install FUSE**:
   ```bash
   # Ubuntu/Debian
   sudo apt install libfuse2

   # Fedora
   sudo dnf install fuse-libs

   # Arch Linux
   sudo pacman -S fuse2
   ```

2. **Extract the AppImage** if FUSE can't be installed:
   ```bash
   ./nvim.appimage --appimage-extract
   ./squashfs-root/usr/bin/nvim
   ```

### Clipboard Integration

If clipboard integration isn't working:

1. **Check clipboard provider**:
   - Inside Neovim, run:
   ```
   :checkhealth provider
   ```

2. **Install xclip or xsel**:
   ```bash
   # Ubuntu/Debian
   sudo apt install xclip

   # Fedora
   sudo dnf install xclip

   # Arch Linux
   sudo pacman -S xclip
   ```

## GUI Options for Linux

### Neovide

[Neovide](https://github.com/neovide/neovide) is a graphical user interface for Neovim:

```bash
# Ubuntu/Debian (from source)
sudo apt install -y curl \
    gnupg ca-certificates git \
    gcc-multilib g++-multilib cmake libssl-dev pkg-config \
    libfreetype6-dev libasound2-dev libexpat1-dev libxcb-composite0-dev \
    libbz2-dev libsndio-dev freeglut3-dev libxmu-dev libxi-dev libfontconfig1-dev
git clone https://github.com/neovide/neovide
cd neovide
cargo build --release
sudo cp target/release/neovide /usr/local/bin/

# Arch Linux
sudo pacman -S neovide
```

### GNOME Neovim

A GNOME GUI for Neovim:

```bash
# Flatpak (any distribution)
flatpak install flathub com.github.vhakulinen.gnvim
```

## Next Steps

Now that you have Neovim installed on Linux, you can:

- Learn about [Neovim Configuration Locations](07-neovim-configuration-locations.md)
- Explore [Upgrading Neovim](06-upgrading-neovim.md)
- Set up a plugin manager and start customizing your Neovim experience

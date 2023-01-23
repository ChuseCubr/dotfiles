#!/usr/bin/env bash

while [[ $# -gt 0 ]]; do
  case $1 in
    --source-dir)
      REPO_PATH="$2"
      shift
      shift
      ;;
    --neovim-install-path)
      INSTALL_PATH="$2"
      shift
      shift
      ;;
    --neovim-build-type)
      BUILD_TYPE="$2"
      shift
      shift
      ;;
    --neovim-nightly)
      NIGHTLY=true
      shift
      shift
      ;;
    -l|--local)
      LOCAL=true
      shift
      ;;
    -r|--remove-source)
      REMOVE=true
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
function nodo {
  sudo -u $SUDO_USER $*
}

if [ ! -e "$USER_HOME/.config" ]; then
  nodo mkdir "$USER_HOME/.config"
fi

if [ ! "$REPO_PATH" ]; then
  REPO_PATH="$USER_HOME/repos"
fi

if [ ! -e "$REPO_PATH" ]; then
  nodo mkdir "$REPO_PATH"
fi

if [ "$LOCAL" ]; then
  INSTALL_PATH="$USER_HOME/.local/bin"
fi

if [ !"$BUILD_TYPE" ]; then
  BUILD_TYPE="Release"
fi

echo -e "\e[34mUpdating packages...\e[0m"
apt update
apt upgrade -y
echo -e "\e[32mUpdated packages.\e[0m"

echo -e "\e[34mInstalling apt packages...\e[0m"
apt install -y build-essential
echo -e "\e[32mInstalled build-essential.\e[0m"
apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
echo -e "\e[32mInstalled Neovim dependencies.\e[0m"
apt install -y fzf ripgrep
echo -e "\e[32mInstalled apt packages.\e[0m"

echo -e "\e[34mInstalling Node version manager...\e[0m"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | nodo bash -s -- -y
echo -e "\e[32mInstalled Node version manager.\e[0m"

echo -e "\e[34mInstalling Rust...\e[0m"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | nodo sh -s -- -y
echo -e "\e[32mInstalled Rust.\e[0m"

echo -e "\e[34mInstalling Starship...\e[0m"
curl -sS https://starship.rs/install.sh | sh -s -- -y
echo -e "\e[32mInstalled Starship.\e[0m"

echo -e "\e[34mInstalling Neovim...\e[0m"
cd "$REPO_PATH"
nodo git clone https://github.com/neovim/neovim
cd neovim
if [ ! "$NIGHTLY" = true ]; then
  git checkout stable
fi
make CMAKE_BUILD_TYPE=$BUILD_TYPE
if [ "$INSTALL_PATH" ]; then
  make CMAKE_INSTALL_PREFIX="$INSTALL_PATH"
  if [ ! -e "$INSTALL_PATH "]; then
    nodo mkdir -p "$INSTALL_PATH"
  fi
  if [[ ! ":$PATH:" == *"$INSTALL_PATH"* ]]; then
    export PATH="$INSTALL_PATH:$PATH"
  fi
fi
make install
echo -e "\e[32mInstalled Neovim.\e[0m"

echo -e "\e[34mRunning post-installation script...\e[0m"
curl -sSf https://raw.githubusercontent.com/ChuseCubr/dotfiles/wsl/post_install.sh | nodo bash
echo -e "\e[32mFinished setting up WSL!\e[0m"
echo -e "\e[33mPlease run the following commands before running Neovim to complete setup:\e[0m"
echo -e "\t\e[33msource ~/.bashrc\e[0m"
echo -e "\t\e[33mnpm install yarn\e[0m"

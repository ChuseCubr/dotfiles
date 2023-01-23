# dotfiles
echo -e "\e[34mDownloading configuration files...\e[0m"
cd "$HOME/.config"
git init
git branch -m main
git remote add origin https://github.com/chusecubr/dotfiles
git pull origin wsl
git submodule update --init --recursive
git submodule update --remote --recursive
echo -e "\e[32mInstalled configuration files.\e[0m"

# node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install --lts
nvm use --lts

# rust
source "$HOME/.cargo/env"

# starship
if (! grep --quiet "starship" "$HOME/.bashrc"); then
  echo eval \"\$\(starship init bash\)\" >> "$HOME/.bashrc"
fi

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

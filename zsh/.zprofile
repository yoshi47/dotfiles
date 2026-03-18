
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.nodenv/shims:$PATH"

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Nix (must be in .zprofile so smartcache captures it in mise's cached PATH)
if [[ -d "$HOME/.nix-profile/bin" ]]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi

# Machine-local credentials (not managed by chezmoi)
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

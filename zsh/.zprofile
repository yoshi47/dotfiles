
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by Toolbox App
case ":$PATH:" in
  *":$HOME/Library/Application Support/JetBrains/Toolbox/scripts:"*) ;;
  *) export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ;;
esac

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Nix (must be in .zprofile so smartcache captures it in mise's cached PATH)
if [[ -d "$HOME/.nix-profile/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.nix-profile/bin:"*) ;;
    *) export PATH="$HOME/.nix-profile/bin:$PATH" ;;
  esac
fi

# Machine-local credentials (not managed by chezmoi)
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local

plugins=(
    git 
    zsh-autosuggestions 
    zsh-syntax-highlighting 
    kubectl
)

source /home/user/.oh-my-zsh/oh-my-zsh.sh

eval "$(oh-my-posh init zsh --config ~/.config.zsh/ohmyposh/zen.toml)"
